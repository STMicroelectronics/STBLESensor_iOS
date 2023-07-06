//
//  LevelViewController.swift
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

final class LevelViewController: DemoNodeNoViewController<LevelDelegate> {

    let levelSelection: [String] = ["Pitch/Roll", "Pitch", "Roll"]
    var currentLevelSelection: Int = 0
    var mZeroPitch: Float = 0.0
    var mZeroRoll: Float = 0.0
    var mPitch: Float = 0.0
    var mRoll: Float = 0.0
    
    var containerLevelSelectionView = UIView()
    let levelSelectionView = LevelSelectionView()
    
    var containerLevelGraphView = UIView()
    let levelGraphView = LevelGraphView()
    
    var containerZerosButtonView = UIView()
    let zerosButtonView = ZerosButtonView()
    
    var containerPitchRollView = UIView()
    let pitchRollView = PitchRollView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.level.title

        presenter.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        let height = levelGraphView.mainView.frame.height
        let width = levelGraphView.mainView.frame.width
        
        presenter.drawDottedLine(start: CGPoint(x: width/2, y: 0), end: CGPoint(x: width/2, y: height), view: levelGraphView.mainView)
        presenter.drawDottedLine(start: CGPoint(x: 0, y: height/2), end: CGPoint(x: width, y: height/2), view: levelGraphView.mainView)
    }
    
    override func configureView() {
        super.configureView()
        
        containerLevelSelectionView = levelSelectionView.embedInView(with: .standard)
        containerLevelGraphView = levelGraphView.embedInView(with: .standardEmbed)
        containerZerosButtonView = zerosButtonView.embedInView(with: .standardEmbed)
        containerPitchRollView = pitchRollView.embedInView(with: .standardEmbed)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 4, views: [
            containerLevelSelectionView,
            UIView(),
            containerLevelGraphView,
            containerZerosButtonView,
            containerPitchRollView,
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
        
        levelSelectionView.selectionLabel.text = levelSelection[currentLevelSelection]
        
        let changeLevelMeasureTap = UITapGestureRecognizer(target: self, action: #selector(changeLevelMeasureTapped(_:)))
        levelSelectionView.selectionButton.addGestureRecognizer(changeLevelMeasureTap)
        
        let setZeroTap = UITapGestureRecognizer(target: self, action: #selector(setZeroTapped(_:)))
        zerosButtonView.setZeroButton.addGestureRecognizer(setZeroTap)
        
        let resetZeroTap = UITapGestureRecognizer(target: self, action: #selector(resetZeroTapped(_:)))
        zerosButtonView.resetZeroButton.addGestureRecognizer(resetZeroTap)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateLevelUI(with: sample)
        }
    }
}

extension LevelViewController {
    @objc
    func changeLevelMeasureTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeLevelMeasure()
    }
    
    @objc
    func setZeroTapped(_ sender: UITapGestureRecognizer) {
        presenter.setZero()
    }
    
    @objc
    func resetZeroTapped(_ sender: UITapGestureRecognizer) {
        presenter.resetZero()
    }
}
