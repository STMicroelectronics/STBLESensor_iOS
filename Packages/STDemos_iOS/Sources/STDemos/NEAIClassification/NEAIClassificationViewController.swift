//
//  NEAIClassificationViewController.swift
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

final class NEAIClassificationViewController: DemoNodeNoViewController<NEAIClassificationDelegate> {

    let logoImageView = UIImageView()
    let neaiClassTitle = UILabel()
    
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
    
    let results = UILabel()
    
    var outlierSV = UIStackView()
    
    let outlierTitle = UILabel()
    let outlierValue = UILabel()
    
    var showAllClassesSV = UIStackView()
    let showAllClassesLabel = UILabel()
    let showAllClassesSwitch = UISwitch()
    
    var mostProbableClassSV = UIStackView()
    
    let mostProbableClassTitle = UILabel()
    let mostProbableClassValue = UILabel()
    
    var probabilitiesSV = UIStackView()
    let probabilitiesTitle = UILabel()
    
    var prob1SV = UIStackView()
    var prob2SV = UIStackView()
    var prob3SV = UIStackView()
    var prob4SV = UIStackView()
    var prob5SV = UIStackView()
    var prob6SV = UIStackView()
    var prob7SV = UIStackView()
    var prob8SV = UIStackView()
    
    let probability1Label = UILabel()
    let probability2Label = UILabel()
    let probability3Label = UILabel()
    let probability4Label = UILabel()
    let probability5Label = UILabel()
    let probability6Label = UILabel()
    let probability7Label = UILabel()
    let probability8Label = UILabel()
    
    let probability1Progress = UIProgressView()
    let probability2Progress = UIProgressView()
    let probability3Progress = UIProgressView()
    let probability4Progress = UIProgressView()
    let probability5Progress = UIProgressView()
    let probability6Progress = UIProgressView()
    let probability7Progress = UIProgressView()
    let probability8Progress = UIProgressView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.NeaiClassification.Text.titleBar.localized

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
        
        neaiClassTitle.text = Localizer.NeaiClassification.Title.nClass.localized
        TextLayout.title.apply(to: neaiClassTitle)
        neaiClassTitle.textAlignment = .center

        neaiCommandImageView.image = ImageLayout.image(with: "NEAI_gear", in: .module)?.rotate(radians: (.pi/2))?.withTintColor(ColorLayout.primary.light)
        neaiCommandImageView.setDimensionContraints(width: 48, height: 48)
        TextLayout.bold.apply(to: neaiCommandLabel)
        neaiCommandLabel.text = Localizer.NeaiClassification.Text.neaiCommands.localized
        neaiCommandArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        neaiCommandArrowBtn.setTitle(" ", for: .normal)
        
        let neaiCommandsStackView = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            neaiCommandImageView,
            neaiCommandLabel,
            UIView(),
            neaiCommandArrowBtn
        ])
        
        Buttonlayout.lightBlueSecondary.apply(to: startBtn, text: Localizer.NeaiClassification.Action.start.localized)
        Buttonlayout.standard.apply(to: stopBtn, text: Localizer.NeaiClassification.Action.stop.localized)
        
        let neaiClassBtnSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            startBtn,
            stopBtn
        ])
        neaiClassBtnSV.distribution = .fill
        
        let expandOrHideStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            neaiClassBtnSV
        ])
        expandOrHideStackView.distribution = .fill
        neaiExpandOrHideStackView = expandOrHideStackView
        
        let separatorView1 = UIView()
        separatorView1.backgroundColor = ColorLayout.stGray6.light
        separatorView1.setDimensionContraints(height: 1)
        
        aiEngineLabel.text = Localizer.NeaiClassification.Text.aiEngine.localized
        TextLayout.bold.apply(to: aiEngineLabel)
        
        phaseTile.text = Localizer.NeaiClassification.Text.phaseTitle.localized
        TextLayout.info.apply(to: phaseTile)
        phaseValue.text = Localizer.NeaiClassification.Text.noValue.localized
        
        let phaseSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            phaseTile,
            phaseValue
        ])
        phaseSV.distribution = .fill
        
        stateTile.text = Localizer.NeaiClassification.Text.state.localized
        TextLayout.info.apply(to: stateTile)
        stateValue.text = Localizer.NeaiClassification.Text.noValue.localized
        
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
        
        results.text = Localizer.NeaiClassification.Text.results.localized
        TextLayout.bold.apply(to: results)
        
        outlierTitle.text = Localizer.NeaiClassification.Text.mostProbableClass.localized
        TextLayout.bold.apply(to: outlierTitle)
        outlierValue.text = Localizer.NeaiClassification.Outlier.yes.localized
        TextLayout.largetitle.apply(to: outlierValue)
        
        outlierSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            outlierTitle,
            outlierValue
        ])
        
        showAllClassesLabel.text = Localizer.NeaiClassification.Text.showAllClasses.localized
        TextLayout.info.apply(to: showAllClassesLabel)
        showAllClassesLabel.textAlignment = .right
        showAllClassesSwitch.isOn = false
        
        showAllClassesSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            showAllClassesLabel,
            showAllClassesSwitch
        ])
        phaseSV.alignment = .trailing
        
        let resultsSV = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            results,
            outlierSV,
            showAllClassesSV
        ])
        
        mostProbableClassTitle.text = Localizer.NeaiClassification.Text.mostProbableClass.localized
        TextLayout.bold.apply(to: mostProbableClassTitle)
        
        mostProbableClassValue.text = Localizer.NeaiClassification.Text.unknown.localized
        TextLayout.largetitle.apply(to: mostProbableClassValue)
        
        mostProbableClassSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            mostProbableClassTitle,
            mostProbableClassValue
        ])
        
        probabilitiesTitle.text = Localizer.NeaiClassification.Text.probabilities.localized
        TextLayout.bold.apply(to: probabilitiesTitle)
        
        probability1Label.text = "CL 1 (0%): "
        probability1Progress.setProgress(0, animated: true)
        probability1Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability1Label)
        prob1SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability1Label,
            probability1Progress
        ])
        prob1SV.alignment = .center
        
        probability2Label.text = "CL 2 (0%): "
        probability2Progress.setProgress(0, animated: true)
        probability2Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability2Label)
        prob2SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability2Label,
            probability2Progress
        ])
        prob2SV.alignment = .center
        
        probability3Label.text = "CL 3 (0%): "
        probability3Progress.setProgress(0, animated: true)
        probability3Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability3Label)
        prob3SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability3Label,
            probability3Progress
        ])
        prob3SV.alignment = .center
        
        probability4Label.text = "CL 4 (0%): "
        probability4Progress.setProgress(0, animated: true)
        probability4Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability4Label)
        prob4SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability4Label,
            probability4Progress
        ])
        prob4SV.alignment = .center
        
        probability5Label.text = "CL 5 (0%): "
        probability5Progress.setProgress(0, animated: true)
        probability5Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability5Label)
        prob5SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability5Label,
            probability5Progress
        ])
        prob5SV.alignment = .center
        
        probability6Label.text = "CL 6 (0%): "
        probability6Progress.setProgress(0, animated: true)
        probability6Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability6Label)
        prob6SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability6Label,
            probability6Progress
        ])
        prob6SV.alignment = .center
        
        probability7Label.text = "CL 7 (0%): "
        probability7Progress.setProgress(0, animated: true)
        probability7Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability7Label)
        prob7SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability7Label,
            probability7Progress
        ])
        prob7SV.alignment = .center
        
        probability8Label.text = "CL 8 (0%): "
        probability8Progress.setProgress(0, animated: true)
        probability8Progress.progressTintColor = ColorLayout.primary.light
        TextLayout.info.apply(to: probability8Label)
        prob8SV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            probability8Label,
            probability8Progress
        ])
        prob8SV.alignment = .center
        
        probabilitiesSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            probabilitiesTitle,
            prob1SV,
            prob2SV,
            prob3SV,
            prob4SV,
            prob5SV,
            prob6SV,
            prob7SV,
            prob8SV,
        ])
        
        let separatorView3 = UIView()
        separatorView3.backgroundColor = ColorLayout.stGray6.light
        separatorView3.setDimensionContraints(height: 1)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            logoImageView,
            neaiClassTitle,
            neaiCommandsStackView,
            neaiExpandOrHideStackView,
            separatorView1,
            aiEngineSV,
            separatorView2,
            resultsSV,
            mostProbableClassSV,
            probabilitiesSV,
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
        
        let startTap = UITapGestureRecognizer(target: self, action: #selector(startBtnTapped(_:)))
        startBtn.addGestureRecognizer(startTap)
        
        let stopTap = UITapGestureRecognizer(target: self, action: #selector(stopBtnTapped(_:)))
        stopBtn.addGestureRecognizer(stopTap)
        
        let showAllClassesTap = UITapGestureRecognizer(target: self, action: #selector(showAllClassesSwitchTapped(_:)))
        showAllClassesSwitch.addGestureRecognizer(showAllClassesTap)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateNEAIClassificationUI(with: sample)
        }
    }
}

extension NEAIClassificationViewController {
    @objc
    func expandOrHideBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.expandOrHideNEAICommands()
    }
    
    @objc
    func startBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startClassification()
    }
    
    @objc
    func stopBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.stopClassification()
    }
    
    @objc
    func showAllClassesSwitchTapped(_ sender: UITapGestureRecognizer) {
        presenter.showAllClassesSwitchTapped()
    }
}
