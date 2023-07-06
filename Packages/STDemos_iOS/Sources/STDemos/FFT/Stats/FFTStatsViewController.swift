//
//  FFTStatsViewController.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI

public class FFTStatsViewController: BaseViewController<FFTStatsDelegate, FFTStatsView> {

    private static let FREQ_MAX_FORMAT = {
        return  NSLocalizedString("%@ Max: %.4f @ %.2f Hz",
                                  tableName: nil,
                                  bundle: .module,
                                  value: "%@ Max: %.4f @ %.2f Hz",
                                  comment: "%@ Max: %.4f @ %.2f Hz");
    }()
    private static let TIME_STAT_FORMAT = {
        return  NSLocalizedString("%@ Acc Peack: %.4f %@\n\tRMS Spped: %.2f %@",
                                  tableName: nil,
                                  bundle: .module,
                                  value: "%@ Acc Peack: %.2f %@\n\tRMS Spped: %.2f %@",
                                  comment: "%@ Acc Peack: %.2f %@\n\tRMS Spped: %.2f %@");
    }()
    private static let TIME_STATS_UNAVAILABLE = {
        return  NSLocalizedString("Not Available",
                                  tableName: nil,
                                  bundle: .module,
                                  value: "Not Available",
                                  comment: "Not Available");
    }()
    
    public override func makeView() -> FFTStatsView {
        FFTStatsView.make(with: Bundle.module) as? FFTStatsView ?? FFTStatsView()
    }

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Alert_title"

        presenter.load()
    }

    public override func configureView() {
        super.configureView()

        view.backgroundColor = .clear
        mainView.backgroundColor = .clear
    }

}

extension FFTStatsViewController {
    func configureView(with alertFFTDetails: AlertFFTDetails)  {
        
        if let maxPoints = alertFFTDetails.fftDetails?.fftPoint {
            displayMaxPoint(maxPoints)
        }
        
        mainView.fftStatsTimeX.text = String(format: FFTStatsViewController.TIME_STAT_FORMAT,
                                             LINE_CONFIG[0].name,
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.accX ?? "",
                                             "m/sˆ2",
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.speedX ?? "",
                                             "mm/s")
        mainView.fftStatsTimeY.text = String(format: FFTStatsViewController.TIME_STAT_FORMAT,
                                             LINE_CONFIG[0].name,
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.accY ?? "",
                                             "m/sˆ2",
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.speedY ?? "",
                                             "mm/s")
        mainView.fftStatsTimeZ.text = String(format: FFTStatsViewController.TIME_STAT_FORMAT,
                                             LINE_CONFIG[0].name,
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.accZ ?? "",
                                             "m/sˆ2",
                                             alertFFTDetails.fftDetails?.fftTimeDataInfo?.speedZ ?? "",
                                             "mm/s")

        mainView.actionButton.setTitle("Close", for: .normal)
        mainView.actionButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
    
    private func displayMaxPoint(_ maxPoints: [FFTPoint]) {
        if maxPoints.isEmpty {
            return
        }
     
        //prepare the text
        let texts = zip(LINE_CONFIG, maxPoints).map{ (arg) -> String in
            let (lineConf, values) = arg
            return String(format: FFTStatsViewController.FREQ_MAX_FORMAT,
                          lineConf.name,values.amplitude,values.frequency)
        }
        //hide the labels
        let labels = [self.mainView.fftStatsFrequencyX, self.mainView.fftStatsFrequencyY, self.mainView.fftStatsFrequencyZ]
        labels.forEach{ $0?.isHidden = true}
        //show the availble data
        zip(labels,texts).forEach{ label, value in
            label?.isHidden = false
            label?.text = value
        }
    }
}

