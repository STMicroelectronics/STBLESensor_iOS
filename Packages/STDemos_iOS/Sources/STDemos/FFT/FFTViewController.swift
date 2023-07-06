//
//  FFTViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import Charts

final class FFTViewController: DemoNodeNoViewController<FFTDelegate> {

    let fftDetailButton = UIButton()
    let fftProgress = UIProgressView()
    let chart = LineChartView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.fft.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        fftProgress.setProgress(0, animated: true)
        fftProgress.progressTintColor = ColorLayout.primary.light
        
        Buttonlayout.textPrimaryColor.apply(to: fftDetailButton, text: "DETAILS")
        
        let horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            fftDetailButton
        ])
        horizontalSV.distribution = .fill
        
        setUpCharts()
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            chart,
            fftProgress,
            horizontalSV
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let detailButtonTap = UITapGestureRecognizer(target: self, action: #selector(detailButtonTapped(_:)))
        fftDetailButton.addGestureRecognizer(detailButtonTap)
    }
    
    private func setUpCharts(){
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.chartDescription.enabled=false
        chart.isMultipleTouchEnabled=false
        chart.noDataText = "Acquisition ongoing..."
        
        let legend = chart.legend
        legend.drawInside = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical

//        chart.noDataTextColor = UIColor.label
//        chart.xAxis.labelTextColor = UIColor.label
//        chart.leftAxis.labelTextColor = UIColor.label
//        legend.textColor = .label
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateFFT(with: sample)
        }
    }
}

extension FFTViewController {
    @objc
    func detailButtonTapped(_ sender: UITapGestureRecognizer) {
        presenter.detailButtonTapped()
    }
}
