//
//  NEAIExtrapolationViewController.swift
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

final class NEAIExtrapolationViewController: DemoNodeNoViewController<NEAIExtrapolationDelegate> {
    
    let logoImageView = UIImageView()
    let NeaiExtrapolationTitle = UILabel()
    
    var neaiExpandOrHideStackView = UIStackView()
    
    let neaiCommandImageView = UIImageView()
    let neaiCommandLabel = UILabel()
    let neaiCommandArrowBtn = UIButton()
    
    let startBtn = UIButton()
    let stopBtn = UIButton()
    
    let aiEngineLabel = UILabel()
    
    let phaseTile = UILabel()
    let phaseValue = UILabel()
    
    let stateTile = UILabel()
    let stateValue = UILabel()
    
    let result = UILabel()
    
    var targetSV = UIStackView()
    
    var stubView = UIStackView()
    
    let targetTitle = UILabel()
    
    let targetUnitValue = UILabel()
    
    override func configure() {
        super.configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.neaiExtrapolation.title
        
        presenter.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.enableNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.disableNotification()
    }
    
    override func configureView() {
        super.configureView()
        
        logoImageView.image = ImageLayout.image(with: "NEAI_logo", in: .module)
        logoImageView.setDimensionContraints(width: 100, height: 110)
        logoImageView.contentMode = .scaleAspectFit
        
        NeaiExtrapolationTitle.text = "Extrapolation"
        TextLayout.title.apply(to: NeaiExtrapolationTitle)
        NeaiExtrapolationTitle.textAlignment = .center
        
        neaiCommandImageView.image = ImageLayout.image(with: "NEAI_gear", in: .module)?.rotate(radians: (.pi/2))?.withTintColor(ColorLayout.primary.light)
        neaiCommandImageView.setDimensionContraints(width: 48, height: 48)
        TextLayout.bold.apply(to: neaiCommandLabel)
        neaiCommandLabel.text = "NEAI Commands"
        neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        neaiCommandArrowBtn.setTitle(" ", for: .normal)
        
        let neaiCommandsStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            neaiCommandImageView,
            neaiCommandLabel,
            UIView(),
            neaiCommandArrowBtn
        ])
        
        Buttonlayout.lightBlueSecondary.apply(to: startBtn, text: "START")
        Buttonlayout.standard.apply(to: stopBtn, text: "STOP")
        
        let neaiExtrapolationBtnSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            startBtn,
            stopBtn
        ])
        neaiExtrapolationBtnSV.distribution = .fill
        
        let expandOrHideStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            neaiExtrapolationBtnSV
        ])
        expandOrHideStackView.distribution = .fill
        neaiExpandOrHideStackView = expandOrHideStackView
        
        let separatorView1 = UIView()
        separatorView1.backgroundColor = ColorLayout.stGray6.light
        separatorView1.setDimensionContraints(height: 1)
        
        aiEngineLabel.text = "AI Engine"
        TextLayout.bold.apply(to: aiEngineLabel)
        
        phaseTile.text = "Phase: "
        TextLayout.info.apply(to: phaseTile)
        phaseValue.text = "---"
        
        let phaseSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            phaseTile,
            phaseValue
        ])
        phaseSV.distribution = .fill
        phaseSV.alignment = .trailing
        
        stateTile.text = "State: "
        TextLayout.info.apply(to: stateTile)
        stateValue.text = "---"
        
        let stateSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            stateTile,
            stateValue
        ])
        stateSV.distribution = .fill
        
        let aiEngineSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            aiEngineLabel,
            phaseSV,
            stateSV
        ])
        
        let separatorView2 = UIView()
        separatorView2.backgroundColor = ColorLayout.stGray6.light
        separatorView2.setDimensionContraints(height: 1)
        
        result.text = "Result"
        TextLayout.bold.apply(to: result)
        
        targetTitle.text = "Target: "
        TextLayout.bold.apply(to: targetTitle)
        
        targetSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            targetTitle,
            targetUnitValue
        ])
        
        targetUnitValue.text = "---"
        TextLayout.largetitle.apply(to: targetUnitValue)
        
        let resultsSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            result,
            targetSV
        ])
        
        let stubString = UILabel()
        stubString.text = "DEMO MODE"
        TextLayout.bold.apply(to: stubString)
        
        let stubImage = UIImageView()
        stubImage.image = UIImage(systemName: "info.circle")?.maskWithColor(color: ColorLayout.primary.light)
        
        let stubImageString = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            stubImage,
            stubString
        ])
        
        stubView = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            stubImageString,
            UIView()
        ])
        stubView.distribution = .equalCentering
        
        let stubTap = UITapGestureRecognizer(target: self, action: #selector(stubBtnTapped(_:)))
        stubView.addGestureRecognizer(stubTap)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            logoImageView,
            NeaiExtrapolationTitle,
            neaiCommandsStackView,
            neaiExpandOrHideStackView,
            separatorView1,
            stubView,
            aiEngineSV,
            separatorView2,
            resultsSV
        ])
        
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
        
        let expandOrHideTap = UITapGestureRecognizer(target: self, action: #selector(expandOrHideBtnTapped(_:)))
        neaiCommandArrowBtn.addGestureRecognizer(expandOrHideTap)
        
        let startTap = UITapGestureRecognizer(target: self, action: #selector(startBtnTapped(_:)))
        startBtn.addGestureRecognizer(startTap)
        
        let stopTap = UITapGestureRecognizer(target: self, action: #selector(stopBtnTapped(_:)))
        stopBtn.addGestureRecognizer(stopTap)
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {
        
        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateNEAIExtrapolationUI(with: sample)
        }
    }
}

extension NEAIExtrapolationViewController {
    @objc
    func expandOrHideBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.expandOrHideNEAICommands()
    }
    
    @objc
    func startBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startExtrapolation()
    }
    
    @objc
    func stopBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.stopExtrapolation()
    }
    
    @objc
    func stubBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.howRemoveStubMode()
    }
}
