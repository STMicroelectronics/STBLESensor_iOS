//
//  MainView.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class MainView: UIView {

    @IBOutlet weak var tabBarViewHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabBarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewOffsetConstraint: NSLayoutConstraint!
    
    @IBOutlet public weak var childContainerView: UIView!
    @IBOutlet public weak var tabBarContainerView: UIView!

    public let tabBarView = TabBarView(with: nil)

    public override func awakeFromNib() {
        super.awakeFromNib()

        tabBarContainerView.backgroundColor = .clear
        
        tabBarContainerView.addSubview(tabBarView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ])
    }

}
