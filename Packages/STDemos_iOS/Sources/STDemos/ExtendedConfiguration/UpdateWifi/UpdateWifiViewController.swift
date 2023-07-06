//
//  UpdateWifiViewController.swift
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
import STCore
import STBlueSDK

final class UpdateWifiViewController: BaseNoViewController<UpdateWifiDelegate> {

    let ssidField = UITextField()
    let passwordField = UITextField()
    let securityLabel = UILabel()
    let securityButton = UIButton()
    let securityIcon = UIImageView(image: ImageLayout.image(with: "img_arrow_fill_down"))

//    static func presentFrom(viewController: UIViewController, security: String, completion: @escaping Completion) {
//        let controller = UpdateWifiSettingsViewController()
//        let navController = UINavigationController(rootViewController: controller)
//        controller.didChangeSettings = completion
//        controller.setSecurity(security)
//
//        viewController.present(navController, animated: true, completion: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Updatewifi.Text.credentialTitle.localized

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel) { [weak self] _ in
            self?.presenter.dismiss()
        }

        navigationItem.leftBarButtonItem = cancelButton

        let doneButton = UIBarButtonItem(title: Localizer.Updatewifi.Action.done.localized,
                                         style: .done) { [weak self] _ in
            self?.presenter.done()
        }

        navigationItem.rightBarButtonItem = doneButton

//        securityIcon.setDimensionContraints(width: 10, height: nil)
        securityIcon.contentMode = .scaleAspectFit

        let securityStack = UIStackView.getHorizontalStackView(withSpacing: 8, views: [securityLabel, securityButton, securityIcon])
        let verticalStack = UIStackView.getVerticalStackView(withSpacing: 4, views: [ssidField, passwordField, securityStack])

        securityLabel.font = UIFont.systemFont(ofSize: 14)
        securityLabel.text = Localizer.Updatewifi.Text.security.localized
        ssidField.placeholder = Localizer.Updatewifi.Text.ssid.localized
        passwordField.placeholder = Localizer.Updatewifi.Text.password.localized
        passwordField.isSecureTextEntry = true
        ssidField.setDimensionContraints(width: nil, height: 44)
        passwordField.setDimensionContraints(width: nil, height: 44)

        securityButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.selectWifiSecurity()
        }

        ssidField.returnKeyType = .next
        passwordField.returnKeyType = .done
        ssidField.delegate = self
        passwordField.delegate = self

        view.addSubview(verticalStack, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])

        presenter.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        ssidField.becomeFirstResponder()
    }

    func setSecurity(_ security: WiFiSettings.WiFiSecurity) {
        securityButton.setTitle(security.rawValue.uppercased(), for: .normal)
    }

    override func configure() {
        super.configure()
    }

    override func configureView() {
        super.configureView()
    }

}

extension UpdateWifiViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ssidField {
            passwordField.becomeFirstResponder()
        } else {
            passwordField.resignFirstResponder()
        }

        return false
    }
}
