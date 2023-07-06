//
//  BeamFormingViewController.swift
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

final class BeamFormingViewController: DemoNodeViewController<BeamFormingDelegate, BeamFormingView> {

    private var mButtonToDirectionMap:[UIButton:BeamFormingDirection]!
    private var mLastSelectedDir:BeamFormingDirection = .unknown;
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.beamforming.title

        presenter.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.startAudioPlayer()
    }
    
    override func configureView() {
        super.configureView()
        
        mButtonToDirectionMap = [
            mainView.mTopButton : .top,
            mainView.mTopRightButton : .topRight,
            mainView.mRightButton : .right,
            mainView.mBottomRightButton : .bottomRight,
            mainView.mBottomButton : .bottom,
            mainView.mBottomLeftButton : .bottomLeft,
            mainView.mLeftButton: .left,
            mainView.mTopLeftButton : .topLeft
        ]

        let topBtnTap = UITapGestureRecognizer(target: self, action: #selector(topBtnTapped(_:)))
        let topRightBtnTap = UITapGestureRecognizer(target: self, action: #selector(topRightBtnTapped(_:)))
        let rightBtnTap = UITapGestureRecognizer(target: self, action: #selector(rightBtnTapped(_:)))
        let bottomRightBtnTap = UITapGestureRecognizer(target: self, action: #selector(bottomRightBtnTapped(_:)))
        let bottomBtnTap = UITapGestureRecognizer(target: self, action: #selector(bottomBtnTapped(_:)))
        let bottomLeftBtnTap = UITapGestureRecognizer(target: self, action: #selector(bottomLeftBtnTapped(_:)))
        let leftBtnTap = UITapGestureRecognizer(target: self, action: #selector(leftBtnTapped(_:)))
        let topLeftBtnTap = UITapGestureRecognizer(target: self, action: #selector(topLeftBtnTapped(_:)))
        
        mainView.mTopButton.addGestureRecognizer(topBtnTap)
        mainView.mTopRightButton.addGestureRecognizer(topRightBtnTap)
        mainView.mRightButton.addGestureRecognizer(rightBtnTap)
        mainView.mBottomRightButton.addGestureRecognizer(bottomRightBtnTap)
        mainView.mBottomButton.addGestureRecognizer(bottomBtnTap)
        mainView.mBottomLeftButton.addGestureRecognizer(bottomLeftBtnTap)
        mainView.mLeftButton.addGestureRecognizer(leftBtnTap)
        mainView.mTopLeftButton.addGestureRecognizer(topLeftBtnTap)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateBeamformingUI(with: feature, with: sample)
        }
    }
}

extension BeamFormingViewController {
    
    @objc
    func topBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.top)
        resetButtonImage()
        mainView.mTopButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func topRightBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.topRight)
        resetButtonImage()
        mainView.mTopRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func rightBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.right)
        resetButtonImage()
        mainView.mRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func bottomRightBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.bottomRight)
        resetButtonImage()
        mainView.mBottomRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func bottomBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.bottom)
        resetButtonImage()
        mainView.mBottomButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func bottomLeftBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.bottomLeft)
        resetButtonImage()
        mainView.mBottomLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func leftBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.left)
        resetButtonImage()
        mainView.mLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    @objc
    func topLeftBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeDirection(.topLeft)
        resetButtonImage()
        mainView.mTopLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_on", in: .module), for: .normal)
    }
    
    private func resetButtonImage() {
        mainView.mTopButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mTopRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mBottomRightButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mBottomButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mBottomLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
        mainView.mTopLeftButton.setImage(ImageLayout.image(with: "Beamforming_radioButton_off", in: .module), for: .normal)
    }
}
