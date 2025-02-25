//
//  MedicalSignalViewController.swift
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
import DGCharts

final class MedicalSignalViewController: DemoNodeNoViewController<MedicalSignalDelegate> {
    
    var feature16Bit: Feature? = nil
    var feature24Bit: Feature? = nil
    
    var featuresRawControlled: Feature? = nil
    var featuresPnpL: Feature? = nil
    
    let plot16BitStartStopButton = UIButton()
    let plot24BitStartStopButton = UIButton()
    
    let resetChartsZoomButton = UIButton()
    
    var containerMedical16View = UIView()
    let medical16View = MedicalView()
    
    var containerMedical24View = UIView()
    let medical24View = MedicalView()
    
    let syntheticTextTitleView = UILabel()
    let syntheticTextView = UITextView()
    var containerSyntheticView = UIView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.medicalSignal.title

        presenter.load()
    }
    
    override func configureView() {
        super.configureView()
        
        Buttonlayout.standardWithImage(image: ImageLayout.Common.playFilled).apply(to: plot16BitStartStopButton, text: "Start Med16")
        Buttonlayout.standardWithImage(image: ImageLayout.Common.playFilled).apply(to: plot24BitStartStopButton, text: "Start Med24")
        Buttonlayout.standardWithImage(image: UIImage(systemName: "square.arrowtriangle.4.outward")).apply(to: resetChartsZoomButton, text: "Reset")
        
        var viewsForHorizontalStackView: [UIView] = []
        
        if feature16Bit != nil {
            viewsForHorizontalStackView.append(plot16BitStartStopButton)
        }
        
        if ((feature16Bit != nil) || (feature24Bit != nil)) {
            viewsForHorizontalStackView.append(resetChartsZoomButton)
        }
        
        if feature24Bit != nil {
            viewsForHorizontalStackView.append(plot24BitStartStopButton)
        }
        
        
        let horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: viewsForHorizontalStackView)
        
        horizontalSV.setDimensionContraints(height: 50)
        
        containerMedical16View = medical16View.embedInView(with: .standard)
        
        containerMedical16View.layer.borderWidth = 2
        containerMedical16View.layer.cornerRadius = 5
        containerMedical16View.layer.borderColor = ColorLayout.stGray5.light.cgColor
        
        containerMedical24View = medical24View.embedInView(with: .standardEmbed)
        
        containerMedical24View.layer.borderWidth = 2
        containerMedical24View.layer.cornerRadius = 5
        containerMedical24View.layer.borderColor = ColorLayout.stGray5.light.cgColor
        
        syntheticTextTitleView.text = "Synthetic Data:"
        TextLayout.infoBold.apply(to: syntheticTextTitleView)
        
        syntheticTextView.isEditable = false
        syntheticTextView.text="Waiting"
        syntheticTextView.setDimensionContraints(height: 150.0)
        
        let syntheticSV = UIStackView.getVerticalStackView(withSpacing: 1, views: [
            syntheticTextTitleView,
            syntheticTextView])
        
        containerSyntheticView = syntheticSV.embedInView(with: .standardEmbed)
        containerSyntheticView.layer.borderWidth = 2
        containerSyntheticView.layer.cornerRadius = 5
        containerSyntheticView.layer.borderColor = ColorLayout.stGray5.light.cgColor
        
        
        var viewsForMainStackView: [UIView] = [horizontalSV]
        
        if feature16Bit != nil {
            viewsForMainStackView.append(containerMedical16View)
        }
        
        if feature24Bit != nil {
            viewsForMainStackView.append(containerMedical24View)
        }
        
        if featuresRawControlled != nil {
            viewsForMainStackView.append(containerSyntheticView)
        }
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: viewsForMainStackView)
        mainStackView.distribution = .fill
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
        
        let startStopTap16Bit = UITapGestureRecognizer(target: self, action: #selector(startStopTapped16Bit(_:)))
        plot16BitStartStopButton.addGestureRecognizer(startStopTap16Bit)
        
        let startStopTap24Bit = UITapGestureRecognizer(target: self, action: #selector(startStopTapped24Bit(_:)))
        plot24BitStartStopButton.addGestureRecognizer(startStopTap24Bit)
        
        let resetZoomTap =  UITapGestureRecognizer(target: self, action: #selector(resetChartsZoomTapped(_:)))
        resetChartsZoomButton.addGestureRecognizer(resetZoomTap)
        
        medical16View.setUpChart()
        medical24View.setUpChart()
    }
    
    
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            if let feature16 = self?.feature16Bit {
                if feature.type.uuid == feature16.type.uuid {
                    self?.presenter.update16BitPlot(with: sample)
                }
            }
            
            if let feature24 = self?.feature24Bit {
                if feature.type.uuid == feature24.type.uuid {
                    self?.presenter.update24BitPlot(with: sample)
                }
            }
            
            if feature is RawPnPLControlledFeature {
                self?.presenter.updateFeatureValueRawPnPLControlled(with: sample, and: feature)
            }
            
            if feature is PnPLFeature {
                self?.presenter.newPnPLSample(with: sample, and: feature)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.disableAllNotifications()
    }
    
}

extension MedicalSignalViewController {
    @objc
    func startStopTapped16Bit(_ sender: UITapGestureRecognizer) {
        presenter.startStop16BitPlotting()
    }
    
    @objc
    func startStopTapped24Bit(_ sender: UITapGestureRecognizer) {
        presenter.startStop24BitPlotting()
    }
    
    @objc
    func resetChartsZoomTapped(_ sender: UITapGestureRecognizer) {
        presenter.resetChartsZoom()
    }
}
