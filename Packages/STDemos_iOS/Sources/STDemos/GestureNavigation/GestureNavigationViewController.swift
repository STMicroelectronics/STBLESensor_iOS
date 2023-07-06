//
//  GestureNavigationViewController.swift
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

final class GestureNavigationViewController: DemoNodeNoViewController<GestureNavigationDelegate> {

    let gestureLabel = UILabel()
    
    let navUpArrow = UIImageView()
    let navDownArrow = UIImageView()
    let navLeftArrow = UIImageView()
    let navRightArrow = UIImageView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.gestureNavigation.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        gestureLabel.text = "GESTURE FOUND"
        gestureLabel.textAlignment = .center
        gestureLabel.numberOfLines = 0
        
        navUpArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)
        navDownArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)?
            .rotate(radians: .pi)
        navLeftArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)?
            .rotate(radians: (.pi*3)/2)
        navRightArrow.image = ImageLayout.image(with: "gesture_nav_arrow", in: .module)?
            .maskWithColor(color: ColorLayout.secondary.light)?
            .rotate(radians: .pi/2)
        
        navUpArrow.contentMode = .scaleAspectFit
        navDownArrow.contentMode = .scaleAspectFit
        navLeftArrow.contentMode = .scaleAspectFit
        navRightArrow.contentMode = .scaleAspectFit
        
        navUpArrow.alpha = 0
        navDownArrow.alpha = 0
        navLeftArrow.alpha = 0
        navRightArrow.alpha = 0
        
        let row1StackView = UIStackView.getHorizontalStackView(withSpacing: 0, views: [
            UIView(),
            navUpArrow,
            UIView()
        ])
        row1StackView.distribution = .fillEqually
        
        let row2StackView = UIStackView.getHorizontalStackView(withSpacing: 20, views: [
            navLeftArrow,
            gestureLabel,
            navRightArrow
        ])
        row2StackView.distribution = .fillEqually
        
        let row3StackView = UIStackView.getHorizontalStackView(withSpacing: 0, views: [
            UIView(),
            navDownArrow,
            UIView()
        ])
        row3StackView.distribution = .fillEqually
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 0, views: [
            row1StackView,
            row2StackView,
            row3StackView
        ])
        mainStackView.distribution = .fillEqually
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateGestureLabel(with: sample)
        }
    }

}
