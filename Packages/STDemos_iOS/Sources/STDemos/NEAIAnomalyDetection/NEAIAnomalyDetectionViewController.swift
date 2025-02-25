//
//  NEAIAnomalyDetectionViewController.swift
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

final class NEAIAnomalyDetectionViewController: DemoNodeNoViewController<NEAIAnomalyDetectionDelegate> {

    let logoImageView = UIImageView()
    let neaiAdtitle = UILabel()
    
    var neaiExpandOrHideStackView = UIStackView()
    
    let neaiCommandImageView = UIImageView()
    let neaiCommandLabel = UILabel()
    let neaiCommandArrowBtn = UIButton()
    
    let learningLabel = UILabel()
    let learningDetectingSwitch = UISwitch()
    let detectingLabel = UILabel()
    
    let resetKnowledgeBtn = UIButton()
    let startBtn = UIButton()
    
    let aiEngineLabel = UILabel()
    
    let phaseTile = UILabel()
    let phaseValue = UILabel()
    
    let stateTile = UILabel()
    let stateValue = UILabel()
    
    let progressTile = UILabel()
    let progressValue = UILabel()
    let progressBar = UIProgressView()
    
    let results = UILabel()
    
    let statusImage = UIImageView()
    let statusTile = UILabel()
    let statusValue = UILabel()
    
    let similarityImage = UIImageView()
    let similarityTile = UILabel()
    let similarityValue = UILabel()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.NeaiAnomalyDetection.Text.titleTabBar.localized

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
        
        neaiAdtitle.text = Localizer.NeaiAnomalyDetection.Text.title.localized
        TextLayout.title.apply(to: neaiAdtitle)
        neaiAdtitle.textAlignment = .center

        neaiCommandImageView.image = ImageLayout.image(with: "NEAI_gear", in: .module)?.rotate(radians: (.pi/2))?.withTintColor(ColorLayout.primary.light)
        neaiCommandImageView.setDimensionContraints(width: 48, height: 48)
        TextLayout.bold.apply(to: neaiCommandLabel)
        neaiCommandLabel.text = Localizer.NeaiAnomalyDetection.Text.commands.localized
        neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        neaiCommandArrowBtn.setTitle(" ", for: .normal)
        
        let neaiCommandsStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            neaiCommandImageView,
            neaiCommandLabel,
            UIView(),
            neaiCommandArrowBtn
        ])
        
        learningLabel.text = Localizer.NeaiAnomalyDetection.Text.learning.localized
        TextLayout.subtitle.apply(to: learningLabel)
        learningDetectingSwitch.isOn = false
        detectingLabel.text = Localizer.NeaiAnomalyDetection.Text.detecting.localized
        TextLayout.subtitle.apply(to: detectingLabel)
        
        let learningDetectingSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            learningLabel,
            learningDetectingSwitch,
            detectingLabel,
            UIView()
        ])
        learningDetectingSV.distribution = .equalCentering
        
        Buttonlayout.lightBlueSecondary.apply(to: resetKnowledgeBtn, text: Localizer.NeaiAnomalyDetection.Action.resetKnowledge.localized)
        Buttonlayout.standard.apply(to: startBtn, text: Localizer.NeaiAnomalyDetection.Action.start.localized)
        
        let neaiAdBtnSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            resetKnowledgeBtn,
            startBtn
        ])
        neaiAdBtnSV.distribution = .fill
        
        let expandOrHideStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            learningDetectingSV,
            neaiAdBtnSV
        ])
        expandOrHideStackView.distribution = .fill
        neaiExpandOrHideStackView = expandOrHideStackView
        
        let separatorView1 = UIView()
        separatorView1.backgroundColor = ColorLayout.stGray6.light
        separatorView1.setDimensionContraints(height: 1)
        
        aiEngineLabel.text = Localizer.NeaiAnomalyDetection.Text.aiengineTitle.localized
        TextLayout.bold.apply(to: aiEngineLabel)
        
        phaseTile.text = Localizer.NeaiAnomalyDetection.Text.phaseTitle.localized
        TextLayout.info.apply(to: phaseTile)
        phaseValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
        
        
        let phaseSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            phaseTile,
            phaseValue
        ])
        phaseSV.distribution = .fill
        
        stateTile.text = Localizer.NeaiAnomalyDetection.Text.stateTilte.localized
        TextLayout.info.apply(to: stateTile)
        stateValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
        
        let stateSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            stateTile,
            stateValue
        ])
        stateSV.distribution = .fill
        
        progressTile.text = Localizer.NeaiAnomalyDetection.Text.progressTitle.localized
        TextLayout.info.apply(to: progressTile)
        progressValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
        
        progressBar.setProgress(Float(0), animated: true)
        progressBar.progressTintColor = ColorLayout.primary.light
        
        let progressSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            progressTile,
            progressValue
        ])
        progressSV.distribution = .fill
        
        let aiEngineSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            aiEngineLabel,
            phaseSV,
            stateSV,
            progressSV,
            progressBar
        ])
        
        let separatorView2 = UIView()
        separatorView2.backgroundColor = ColorLayout.stGray6.light
        separatorView2.setDimensionContraints(height: 1)
        
        results.text = Localizer.NeaiAnomalyDetection.Text.resultsTitle.localized
        TextLayout.bold.apply(to: results)
        
        statusImage.image = ImageLayout.image(with: "NEAI_warning", in: .module)
        statusImage.setDimensionContraints(width: 24, height: 24)
        statusTile.text = Localizer.NeaiAnomalyDetection.Text.statusTitle.localized
        TextLayout.info.apply(to: statusTile)
        statusValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
        
        let statusSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            statusImage,
            statusTile,
            statusValue
        ])
        statusSV.distribution = .fill
        
        similarityImage.image = .none
        similarityImage.setDimensionContraints(width: 24, height: 24)
        similarityTile.text = Localizer.NeaiAnomalyDetection.Text.similarityTitle.localized
        TextLayout.info.apply(to: similarityTile)
        similarityValue.text = Localizer.NeaiAnomalyDetection.Text.noValue.localized
        
        let similaritySV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            similarityImage,
            similarityTile,
            similarityValue
        ])
        similaritySV.distribution = .fill
        
        let resultsSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            results,
            statusSV,
            similaritySV
        ])
        
        let separatorView3 = UIView()
        separatorView3.backgroundColor = ColorLayout.stGray6.light
        separatorView3.setDimensionContraints(height: 1)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            logoImageView,
            neaiAdtitle,
            neaiCommandsStackView,
            neaiExpandOrHideStackView,
            separatorView1,
            aiEngineSV,
            separatorView2,
            resultsSV,
            separatorView3
        ])
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
        
        let expandOrHideTap = UITapGestureRecognizer(target: self, action: #selector(expandOrHideBtnTapped(_:)))
        neaiCommandArrowBtn.addGestureRecognizer(expandOrHideTap)
        
        let startStopTap = UITapGestureRecognizer(target: self, action: #selector(startStopBtnTapped(_:)))
        startBtn.addGestureRecognizer(startStopTap)
        
        let resetKnowledgeTap = UITapGestureRecognizer(target: self, action: #selector(resetKnowledgeTapped(_:)))
        resetKnowledgeBtn.addGestureRecognizer(resetKnowledgeTap)
        
        let learningDetectingTap = UITapGestureRecognizer(target: self, action: #selector(learningDetectingTapped(_:)))
        learningDetectingSwitch.addGestureRecognizer(learningDetectingTap)
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateNEAIAnomalyDetectionUI(with: sample)
        }
    }
}

extension NEAIAnomalyDetectionViewController {
    @objc
    func expandOrHideBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.expandOrHideNEAICommands()
    }
    
    @objc
    func startStopBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startStop()
    }
    
    @objc
    func resetKnowledgeTapped(_ sender: UITapGestureRecognizer) {
        presenter.resetKnowledge()
    }
    
    @objc
    func learningDetectingTapped(_ sender: UITapGestureRecognizer) {
        presenter.learningDetecting()
    }
}
