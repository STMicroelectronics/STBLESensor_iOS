//
//  IoTCentralAppFormViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK_Gui
import QRCodeReader
import BlueSTSDK

class IoTCentralAppFormViewController: UIViewController {
    
    /** Variables to hold the data from the previous ViewController */
    //var appName: String = ""
    var node: BlueSTSDKNode!
    var cloudAppSelected: CloudApp!
    
    private let appNameLabel = UILabel()
    private var configurationStack: UIStackView!
    private let infoConfigurationLabel = UILabel()
    private let helpConfigurationButton = UIButton()
    
    private let scrollView = UIScrollView()
    private let qrCodeButton = UIButton()
    private let appDomainTitleLabel = UILabel()
    private let subdomainField = UITextField()
    private let domainLabel = UILabel()
    private let apiTokenTitleLabel = UILabel()
    private let apiTokenField = UITextView()
    private let saveButton = UIButton()
    private var mainStack: UIStackView!
    //private var qrAndHelpStack: UIStackView!
    
    private var shareableLinkStack: UIStackView!
    private let shareableLinkLabel = UILabel()
    private let shareableLinkField = UITextField()
    private let shareLinkButton = UIButton()
    
    private var app = IoTCentralApp(subdomain: "", token: "")
    
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.5)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Disable User Interaction for Api Token Field */
        apiTokenField.isUserInteractionEnabled = false
        shareableLinkField.isUserInteractionEnabled = false
        if (cloudAppSelected.shareableLink == nil || cloudAppSelected.shareableLink == ""){
            shareLinkButton.isEnabled = false
            shareLinkButton.isUserInteractionEnabled = false
        }
        
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        /** STACKVIEW HORIZONTAL define position of Info Configuration Label and HELP Configuration Button */
        configurationStack = UIStackView.getHorizontalStackView(withSpacing: 6, views: [
            infoConfigurationLabel,
            helpConfigurationButton
        ])
        
        /** STACKVIEW HORIZONTAL define position of Shareable Link and Share Link Button */
        shareableLinkStack = UIStackView.getHorizontalStackView(withSpacing: 6, views: [
            shareableLinkField,
            shareLinkButton
        ])
        
        /** STACKVIEW HORIZONTAL define [app name - .azureiotcentral.com] */
        let domainView = UIStackView.getHorizontalStackView(withSpacing: 6, views: [
            subdomainField, domainLabel
        ])
        domainView.distribution = .fillEqually
        
        /** MAIN STACKVIEW VERTICAL composed by ->
                - appName
                  [ description - help button ]
                - Shareable Link
                  [ link - share button ]
                - App Name
                  [ appName Field - .azureiotcentral.com ]
                - Api Token
                  QR Code Button
                  Api Token Field
         */
        mainStack = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            appNameLabel,
            configurationStack,
            UIStackView.getVerticalStackView(withSpacing: 12, views: [
                shareableLinkLabel, shareableLinkStack
            ]),
            UIStackView.getVerticalStackView(withSpacing: 12, views: [
                appDomainTitleLabel, domainView
            ]),
            UIStackView.getVerticalStackView(withSpacing: 12, views: [
                apiTokenTitleLabel,
                qrCodeButton,
                apiTokenField
            ])
        ])
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.addSubview(mainStack, constraints: [
            equal(\.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(saveButton, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            equalDimension(\.heightAnchor, to: 44)
        ])
        
        view.addSubview(scrollView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor, toView: saveButton, withAnchor: \.topAnchor, constant: -16)
        ])
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        [subdomainField, apiTokenField, shareableLinkField].forEach { view in
            view.cornerRadius = 12
            view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            view.setDimensionContraints(width: nil, height: 40)
        }
        [subdomainField].forEach { view in
            view.leftViewMode = .always
            let spacer = UIView()
            spacer.setDimensionContraints(width: 16, height: nil)
            view.leftView = spacer
        }
        apiTokenField.heightConstraint?.constant = 200
        
        appNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        infoConfigurationLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        infoConfigurationLabel.numberOfLines = 5
        
        [domainLabel, appDomainTitleLabel, apiTokenTitleLabel, shareableLinkLabel].forEach { view in
            view.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        }
        
        /** Other settings for Label & button in this view*/
        appNameLabel.text = cloudAppSelected.name
        let splittedUrl = cloudAppSelected.url.components(separatedBy: "https://")
        let splittedUrlName = splittedUrl[1].split(separator: ".")
        subdomainField.text = String(splittedUrlName[0])
        app.subdomain = String(splittedUrlName[0])
        infoConfigurationLabel.text = "Here you can configure your Azure Iot Central application. For more information click the help button."
        appDomainTitleLabel.text = "iot.appDomain.title".localizedFromGUI.uppercased()
        apiTokenTitleLabel.text = "iot.apiToken.title".localizedFromGUI.uppercased()
        shareableLinkLabel.text = "SHAREABLE LINK".localizedFromGUI.uppercased()
        apiTokenField.font = UIFont.systemFont(ofSize: 17)
        domainLabel.text = ".\(IoTCentralApp.domain)"
        domainLabel.textColor = currentTheme.color.secondaryText
        qrCodeButton.backgroundColor = currentTheme.color.primary
        //helpConfigurationButton.backgroundColor = currentTheme.color.primary
        
        /**Help Button that contains instruction for Sharable Link*/
        helpConfigurationButton.setImage(UIImage.namedFromGUI("ic_help"), for: .normal)
        helpConfigurationButton.setTitleColor(.white, for: .normal)
        helpConfigurationButton.setDimensionContraints(width: 64, height: 64)
        helpConfigurationButton.tintColor = currentTheme.color.primary
        helpConfigurationButton.onTap { [weak self]  _ in
            self?.showConfigurationHelpController()
        }
        
        /**Shareable Link Button for sending Sharable Link via email */
        shareLinkButton.setImage(UIImage.namedFromGUI("icon_share"), for: .normal)
        shareLinkButton.setTitleColor(.white, for: .normal)
        shareLinkButton.setDimensionContraints(width: 64, height: 64)
        shareLinkButton.tintColor = currentTheme.color.primary
        shareLinkButton.onTap { [weak self]  _ in
            self?.shareLinkOptions()
        }
        
        /**QR Code Button that allows you to scan Microsoft QR code (copy and paste into app of API Token) */
        qrCodeButton.setTitle("iot.scan.qrcode.title".localizedFromGUI, for: .normal)
        qrCodeButton.setImage(UIImage.namedFromGUI("icon_qrcode"), for: .normal)
        qrCodeButton.setTitleColor(.white, for: .normal)
        qrCodeButton.setDimensionContraints(width: nil, height: 44)
        qrCodeButton.tintColor = .white
        qrCodeButton.onTap { [weak self]  _ in
            self?.scanQRCode()
        }
        
        /**SAVE Button that allows you to save information about your Azure IoT Central Application */
        saveButton.backgroundColor = currentTheme.color.primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("iot.save.title".localizedFromGUI, for: .normal)
        saveButton.onTap { [weak self] _ in
            self?.saveApp()
        }
        
        /** SET SharableLinkField */
        shareableLinkField.text = cloudAppSelected.shareableLink
        
        subdomainField.onKeyPress { [weak self] value in
            self?.app.subdomain = value
            self?.updateUI ()
            return true
        }
        
        /*apiTokenField.onKeyPress { [weak self] value in
            self?.app.token = value
            self?.updateUI ()
            return true
        }*/
        
        manageKeyboard()
        updateUI()
    }
    
    @objc
    private func dismissModal() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is IoTCentralAppsAvailableViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }

    @objc
    private func dismissScreen() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is IoTCentralAppsViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    private func saveApp() {
        guard app.isValid else { return }
        
        IoTAppsController.shared.apps.append(app)
        dismissScreen()
    }
    
    private func scanQRCode() {
        readerVC.completionBlock = { [weak self] result in
            self?.readerVC.dismiss(animated: true, completion: nil)
            
            self?.evaluateQRResult(result?.value)
        }

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet

        present(readerVC, animated: true, completion: nil)
    }
    
    @objc
    private func showConfigurationHelpController() {
        let controller = IoTCentralConfigurationHelpViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    /** Sending options shareable link via: mail, airdrop, Google Drive, ... */
    @objc
    private func shareLinkOptions() {
        /** Set up activity view controller */
        let textToShare = [ shareableLinkField.text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as! [String], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // prevents iPads crash
        
        /** Exclude some activity types from the list : Facebook, Twitter, Flickr, TencentWeibo, Weibo, Vimeo ...*/
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToFacebook
        ]
        
        /** Present the view controller */
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateUI() {
        saveButton.isEnabled = app.isValid
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.5
    }
    
    private func manageKeyboard() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            let height = KeyboardUtilities.getKeyboardHeight(notification)
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -height
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -16
        }
    }
    
    private func evaluateQRResult(_ value: String?) {
        guard let value = value else {
            showAllert(title: "Error".localizedFromGUI, message: "iot.qrcode.invalid".localizedFromGUI)
            return
        }
        
        apiTokenField.text = value
        app.token = value
        updateUI()
    }
    
    /**Function that evaluate QR Code Result (Base64 Coded)
    
    private func evaluateQRResultBase64(_ value: String?) {
        guard let value = value,
              let base64 = Data(base64Encoded: value) else {
            showAllert(title: "Error".localizedFromGUI, message: "iot.qrcode.invalid".localizedFromGUI)
            return
        }

        do {
            let centralQRCode = try JSONDecoder().decode(IoTCentralQRCode.self, from: base64)
            subdomainField.text = centralQRCode.appName
            apiTokenField.text = centralQRCode.apitoken.token
            app.subdomain = centralQRCode.appName
            app.token = centralQRCode.apitoken.token

            updateUI()
        } catch {
            showAllert(title: "Error".localizedFromGUI, message: "iot.qrcode.invalid".localizedFromGUI)
        }
    }
     
    */
    
}
