//
//  FirmwareSelectViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI
import STCore
import JGProgressHUD

class FirmwareSelectViewController: BaseNoViewController<FirmwareSelectDelegate> {
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var firmwareSelectType: FirmwareServiceType = .unknown
    var firmwareType: FirmwareType = .application(board: .other)
    var typeView: STM32FirmwareTypeView?

    let boardInfoView = BoardInfoView(frame: .zero)
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Firmware.Text.title.localized
        
        hud.textLabel.text = "Upgrading..."
        hud.detailTextLabel.text = "0% Complete"
        hud.indicatorView = JGProgressHUDPieIndicatorView()
        hud.interactionType = .blockAllTouches
        
//        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        stackView.addArrangedSubview(boardInfoView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        presenter.load()
        
    }
    
}
