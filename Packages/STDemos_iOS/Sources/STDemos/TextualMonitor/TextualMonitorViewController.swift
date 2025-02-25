//
//  TextualMonitorViewController.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class TextualMonitorViewController: DemoNodeNoViewController<TextualMonitorDelegate> {
    
    var selectedFeature: Feature? = nil
    
    var selectedGPFeatureFormat:  [BleCharacteristicFormat]? = nil
    
    let textualFeatureLabel = UILabel()
    let textualFeatureButton = UIButton()
    let textualStartStopButton = UIButton()
    let logTextView = UITextView()
    
    let playImg = UIImage(named: "ic_play_arrow_24", in: STUI.bundle, compatibleWith: nil)?.maskWithColor(color: ColorLayout.systemWhite.light)
    
    let stopImg = UIImage(named: "ic_stop_24", in: STUI.bundle, compatibleWith: nil)?.maskWithColor(color: ColorLayout.systemWhite.light)
    
    override func configure() {
        super.configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.textual.title
        
        presenter.load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.stopFeatureAtClose()
    }
    
    
    override func configureView() {
        super.configureView()
        
        textualFeatureLabel.text = "None"
        TextLayout.text.apply(to: textualFeatureLabel)
        textualFeatureLabel.numberOfLines = 0
        
        let arrowDownImg = UIImage(systemName: "chevron.down")?.maskWithColor(color: ColorLayout.primary.light)
        textualFeatureButton.setImage(arrowDownImg, for: .normal)
        
        textualStartStopButton.setImage(playImg, for: .normal)
        textualStartStopButton.setDimensionContraints(width: 65, height: 45)
        textualStartStopButton.backgroundColor = ColorLayout.primary.light
        textualStartStopButton.contentMode = .scaleAspectFit
        
        logTextView.isEditable = false
        
        let horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            textualFeatureLabel,
            textualFeatureButton,
            textualStartStopButton
        ])
        
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            horizontalSV,
            logTextView
        ])
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        let featureSelectorTap = UITapGestureRecognizer(target: self, action: #selector(featureSelectorTapped(_:)))
        textualFeatureButton.addGestureRecognizer(featureSelectorTap)
        
        let startStopTap = UITapGestureRecognizer(target: self, action: #selector(startStopTapped(_:)))
        textualStartStopButton.addGestureRecognizer(startStopTap)
        
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {
        
        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        
        DispatchQueue.main.async { [weak self] in
            if let selectedFeature = self?.selectedFeature {
                if feature.type.uuid == selectedFeature.type.uuid {
                    
                    switch feature {
                    case is GeneralPurposeFeature:
                        self?.presenter.updateFeatureValueGP(sample: sample, formats: self?.selectedGPFeatureFormat)
                    case is RawPnPLControlledFeature:
                        self?.presenter.updateFeatureValueRawPnPLControlled(with: sample, and: feature)

                    default:
                        self?.presenter.updateFeatureValue(sample:sample?.description)
                    }
                }
            }
            
            if feature is PnPLFeature {
                self?.presenter.newPnPLSample(with: sample, and: feature)
            }
        }
    }
}

extension TextualMonitorViewController {
    @objc
    func startStopTapped(_ sender: UITapGestureRecognizer) {
        presenter.startStopFeature()
    }
    
    @objc
    func featureSelectorTapped(_ sender: UITapGestureRecognizer) {
        presenter.selectFeature()
    }
}
