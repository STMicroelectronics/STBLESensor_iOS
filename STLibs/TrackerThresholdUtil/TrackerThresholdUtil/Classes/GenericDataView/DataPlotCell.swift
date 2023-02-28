//
//  DataPlotCell.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Charts
import TrackerThresholdUtil

class DataPlotCell: UITableViewCell {
    /// data used to fill the cell field
    public struct Data {
        let name: String
        let samples: [ChartDataEntry]
        let plotRange: ClosedRange<Double>
        let timeRange: ClosedRange<Double>?
    }
    
    @IBOutlet weak var mSensorName: UILabel!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var mChartView: LineChartView!
    @IBAction func onDetailsClicked(_ sender: UIButton) {
        onDetailsClick()
    }
    
    /// function called when the details button is pressed
    public var onDetailsClick: ()->Void  = {}
    
    private var timeRange: ClosedRange<Double>?
    private weak var axisFormatDelegate: IAxisValueFormatter?
    
    /// set the cell with the new data
    ///
    /// - Parameter data: data to display
    public func setup(data: Data) {
        mSensorName.text = data.name
        
        if(data.timeRange == nil){
            setUpChart(plotRange: data.plotRange, timeRange: extractLocalDataTimeRange(data.samples.map { $0.x }))
        } else {
            setUpChart(plotRange: data.plotRange, timeRange: data.timeRange)
        }
        mChartView.data = createDataSet(data: data.samples)
                
        let marker = PillMarker(color: .white, font: UIFont.boldSystemFont(ofSize: 14), textColor: .black)
        mChartView.marker = marker
    }
    
    private func extractLocalDataTimeRange(_ timeSamples: [Double]) -> ClosedRange<Double> {
        let minTimestamp = timeSamples.min() ?? 0
        let maxTimestamp = timeSamples.max() ?? 0
        return minTimestamp...maxTimestamp
    }
}

private extension DataPlotCell {
    /// set up the chart parameters
    ///
    /// - Parameter plotRange: range to use for the y axis
    func setUpChart(plotRange: ClosedRange<Double>, timeRange: ClosedRange<Double>?) {
        self.timeRange = timeRange

        mChartView.leftAxis.axisMaximum = plotRange.upperBound
        mChartView.leftAxis.axisMinimum = plotRange.lowerBound
        mChartView.xAxis.labelPosition = .bottom
        mChartView.xAxis.drawLabelsEnabled = true
        mChartView.rightAxis.enabled = false
        mChartView.chartDescription?.enabled = false
        mChartView.legend.enabled = false
        // x axis range and labels
        if let timeRange = timeRange {
            mChartView.xAxis.axisMinimum = timeRange.lowerBound
            mChartView.xAxis.axisMaximum = timeRange.upperBound
        }
        axisFormatDelegate = self
        mChartView.xAxis.valueFormatter = axisFormatDelegate
        
        if #available(iOS 13, *) {
            mChartView.leftAxis.labelTextColor = UIColor.label
        }
    }
    
    /// create the dataSet
    ///
    /// - Parameter data: points to plot
    /// - Returns: line to plot in the chart
    func createDataSet(data: [ChartDataEntry]) -> LineChartData {
        let dataSet = LineChartDataSet(entries: data, label: nil)
        
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 5
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 2.0
        dataSet.setColor(UIColor.blue)
        
        return LineChartData(dataSet: dataSet)
    }
}

extension DataPlotCell: IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let upperBoud = timeRange?.upperBound,
              let lowerBound = timeRange?.lowerBound else { return "" }
        let difference = upperBoud.rounded() - lowerBound.rounded()
        
        if difference/1000 < 2*24*60*60 {
            return DateFormatter.hour.string(from: value.date)
        } else {
            return DateFormatter.dayMonth.string(from: value.date)
        }
    }
}
