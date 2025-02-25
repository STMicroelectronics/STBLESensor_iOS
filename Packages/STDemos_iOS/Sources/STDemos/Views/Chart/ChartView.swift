//
//  ChartsView.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import DGCharts
import STBlueSDK
import STUI

public enum ChartViewType {
    case all
    case channel(index: Int)
    case module
}

public class ChartView: UIView {

    let xAxisLabel = UILabel()
    let yAxisLabel = UILabel()

    var uom: String = ""

    private let dataStreamer: RawPnplStreamDataBuffer = RawPnplStreamDataBuffer()

    private var timer: Timer?

    private var buttonViews: [UIButton] = []

    public let chartView = LineChartView()

    let buttonsStackView = UIStackView()

    var selectedType: ChartViewType = .all

    public override init(frame: CGRect) {
        super.init(frame: .zero)

        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 0.0

        buttonsStackView.setDimensionContraints(height: 30.0)

        let verticalStackView = UIStackView.getVerticalStackView(withSpacing: 0.0,
                                                                 views: [
                                                                    buttonsStackView.embedInView(with: UIEdgeInsets(top: 0.0,
                                                                                                                    left: 10.0,
                                                                                                                    bottom: 0.0,
                                                                                                                    right: 10.0)),
                                                                    chartView.embedInView(with: UIEdgeInsets(top: 10.0,
                                                                                                             left: 20.0,
                                                                                                             bottom: -20.0,
                                                                                                             right: 20.0))
                                                                 ])

        add(verticalStackView)
        verticalStackView.addFitToSuperviewConstraints()

        setupChartViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChartView {
    func setupChartViews() {

        xAxisLabel.isHidden = true

        yAxisLabel.text = "[uom]"
        TextLayout.info.apply(to: yAxisLabel)
        yAxisLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)

        add(yAxisLabel)
        yAxisLabel.activate(constraints: [
            equal(\.topAnchor, toView: chartView, withAnchor: \.topAnchor),
            equal(\.centerXAnchor, toView: chartView, withAnchor: \.leftAnchor, constant: -10.0),
            equal(\.widthAnchor, toView: yAxisLabel, withAnchor: \.heightAnchor)
        ])

        xAxisLabel.text = "[s]"
        TextLayout.info.apply(to: xAxisLabel)

        add(xAxisLabel)
        xAxisLabel.activate(constraints: [
            equal(\.rightAnchor, toView: chartView, withAnchor: \.rightAnchor),
            equal(\.bottomAnchor, toView: chartView, withAnchor: \.bottomAnchor, constant: 10.0)
        ])

        chartView.setDimensionContraints(height: 300.0)
        chartView.autoScaleMinMaxEnabled = true

        chartView.rightAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom

        chartView.xAxis.drawLabelsEnabled = false

        chartView.leftAxis.drawZeroLineEnabled = true
        chartView.rightAxis.drawZeroLineEnabled = true

        chartView.dragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false

        chartView.chartDescription.enabled = false
        chartView.isMultipleTouchEnabled = false
        chartView.noDataText = "Device is logging.\nClick on \"Current sensor\" field and select a sensor to view its stream in real time..."
        
        let legend = chartView.legend
        legend.drawInside = false
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
    }

    func drawPlot(channels: [RawPnplChannel], type: ChartViewType) {

        xAxisLabel.isHidden = false

        var dataSets: [LineChartDataSet] = []

        var channelsDataEntries: [[ChartDataEntry]] = []

        let entries = channels.channelsDataEntries(with: dataStreamer.seekIndex)

        var config: LineConfig?

        if buttonsStackView.arrangedSubviews.count == 0 && channels.count == 3 {

            var button = UIButton(type: .custom)
            buttonViews.append(button)
            Buttonlayout.smallSelected.apply(to: button, text: "All")
            button.isSelected = true
            button.onTap { [weak self] button in
                self?.selectedType = .all
                self?.refreshButtonsStatus(selected: button)
                self?.reset(all: false, uom: self?.uom ?? "")
            }

            buttonsStackView.addArrangedSubview(button.embedInView(with: .smallEmbed))

            button = UIButton(type: .custom)
            buttonViews.append(button)
            button.isSelected = false
            Buttonlayout.smallSelected.apply(to: button, text: "Mod")
            button.onTap { [weak self] button in
                self?.selectedType = .module
                self?.refreshButtonsStatus(selected: button)
                self?.reset(all: false, uom: self?.uom ?? "")
            }

            buttonsStackView.addArrangedSubview(button.embedInView(with: .smallEmbed))

            if channels.count > 1 {
                for channel in 0..<channels.count {
                    let button = UIButton(type: .custom)
                    buttonViews.append(button)
                    button.isSelected = false
                    Buttonlayout.smallSelected.apply(to: button, text: channels[channel].config.name)
                    button.onTap { [weak self] button in
                        self?.selectedType = .channel(index: channel)
                        self?.refreshButtonsStatus(selected: button)
                        self?.reset(all: false, uom: self?.uom ?? "")
                    }
                    buttonsStackView.addArrangedSubview(button.embedInView(with: .smallEmbed))
                }
            }
        }

        switch selectedType {
        case .all:
            channelsDataEntries = entries
        case .channel(let index):
            channelsDataEntries = [ entries[index] ]
            config = channels[index].config
        case .module:
            channelsDataEntries = entries.module() ?? []
            config = LineConfig(name: "Mod", color: UIColor(sentence: "mod"))
        }

        if chartView.data == nil {
            for (index, channelsDataEntry) in channelsDataEntries.enumerated() {
                dataSets.append(buildChartDataSet(dataEntries: channelsDataEntry,
                                                  conf: config ?? channels[index].config))
            }

            chartView.data = LineChartData(dataSets: dataSets)
        } else {
            chartView.data?.add(channelsEntries: channelsDataEntries,
                                visibleWindowSize: dataStreamer.visibleWindowSize)

            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        }

        guard let channel = channels.first else { return }

        // TODO: remove compoundUom

//        yAxisLabel.text = "[\(channel.compoundUom)]"
        yAxisLabel.text = "[\(uom)]"
    }

    private func buildChartDataSet(dataEntries: [ChartDataEntry], conf: LineConfig) -> LineChartDataSet {
        let line = LineChartDataSet(entries: dataEntries, label: conf.name)

        line.drawCirclesEnabled = false
        line.drawIconsEnabled = false
        line.drawValuesEnabled = false
        line.setDrawHighlightIndicators(false)
        line.lineWidth = conf.lineWidth
        line.setColor(conf.color)
        line.mode = .linear

        chartView.leftAxis.forceLabelsEnabled = true

        return line
    }

    private func refreshButtonsStatus(selected: UIButton) {
        for button in buttonViews {
            button.isSelected = button === selected
        }
    }
}

public extension ChartView {
    func reset(all: Bool = true, uom: String) {
        if all {
            buttonViews.removeAll()
            buttonsStackView.removeAllArrangedSubviews()
            selectedType = .all
        }
        dataStreamer.reset()

        self.uom = uom
        yAxisLabel.text = ""

        xAxisLabel.isHidden = true

        chartView.data = nil
        chartView.resetViewPortOffsets()
        chartView.notifyDataSetChanged()
    }

    func updatePlot(with streams: [RawPnPLStreamEntry], type: ChartViewType = .all, uom: String?) {

        guard let stream = streams.first else { return }

        dataStreamer.addEntries(from: stream, uom: uom)

        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: dataStreamer.odrTimerInterval,
                                         repeats: true,
                                         block: { [weak self] _ in

                guard let self else { return }

                if self.dataStreamer.isDataReady {
                    if let data = self.dataStreamer.nextAvailableData {
                        self.drawPlot(channels: data, type: type)
                    }
                }
            })
        }
    }
}

public extension Array where Element == [ChartDataEntry] {
    func module() -> [[ChartDataEntry]]? {
        guard count == 3 else {
            return nil
        }

        let xArray = self[0]
        let yArray = self[1]
        let zArray = self[2]

        guard xArray.count == yArray.count, yArray.count == zArray.count else {
            return nil
        }

        var module = [ChartDataEntry]()

        for i in 0..<xArray.count {
            let moduleValue = sqrt(pow(xArray[i].y, 2) + pow(yArray[i].y, 2) + pow(zArray[i].y, 2))
            module.append(ChartDataEntry(x: xArray[i].x, y: moduleValue))
        }

        return [ module ]
    }
}

public extension Array where Element == RawPnplChannel {
    func channelsDataEntries(with seekIndex: Int) -> [[ChartDataEntry]] {
        var channelsDataEntries: [[ChartDataEntry]] = []

        for (channelIndex, channel) in self.enumerated() {
            channelsDataEntries.append([])
            for (index, entry) in channel.entries.enumerated() {
                channelsDataEntries[channelIndex].append(ChartDataEntry(x: Double(index) + Double(seekIndex), y: Double(entry)))
            }
        }

        return channelsDataEntries.map { Array<ChartDataEntry>.resample(array: $0, toSize: 1) }
    }
}
