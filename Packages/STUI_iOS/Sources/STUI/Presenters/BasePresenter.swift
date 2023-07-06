//
//  BasePresenter.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import MessageUI
import STCore

public enum NavigationGroup {
    case left
    case right
}

public protocol Presenter: AnyObject {
    func start() -> UIViewController
}

public protocol Presentable: UIViewController {
    associatedtype Presenter

    init(presenter: Presenter)

    func configure(presenter: Presenter)
}

public struct SettingsAction {
    public let name: String
    public var style: UIAlertAction.Style
    public let handler: () -> Void

    public init(name: String, style: UIAlertAction.Style = .default, handler: @escaping () -> Void) {
        self.name = name
        self.style = style
        self.handler = handler
    }
}

open class BasePresenter<View: Presentable, Param>: Presenter {
    
    public var settingsButton = UIBarButtonItem(
        image: ImageLayout.Common.accountGear?.template,
        style: .plain,
        target: nil,
        action: nil
    )
    
    public var settingActions: [SettingsAction] = [SettingsAction]()
    
    public var param: Param

    // swiftlint:disable implicitly_unwrapped_optional
    public weak var view: View!
    // swiftlint:enable implicitly_unwrapped_optional

    public init(param: Param) {
        self.param = param
    }

    public func configure(view: View, param: Param) {
        self.view = view
        self.param = param
    }
    
    public func start() -> UIViewController {
        let viewController = create()
        viewDidCreate()
        return viewController
    }
    
    open func viewDidCreate() {
    }

    open func prepareSettingsMenu() {

        guard !settingActions.isEmpty else { return }

        settingActions.append(SettingsAction(name: Localizer.Common.cancel.localized,
                                             style: .cancel,
                                             handler: {
        }))

//        let settingsButton = UIBarButtonItem(image: ImageLayout.Common.accountGear?.template,
//                                             style: .plain, target: nil, action: nil)

        settingsButton.onTap { [weak self] item in
            guard let self = self else { return }

            let actions = self.settingActions.map { action in
                UIAlertAction(title: action.name,
                              style: action.style) { _ in
                    action.handler()
                }
            }

            UIAlertController.presentAlert(from: self.view,
                                           title: "SETTINGS",
                                           style: .actionSheet,
                                           actions: actions)
        }

        view.navigationItem.rightBarButtonItems = [settingsButton]
    }

    open func addNavigationButton(with image: UIImage?,
                                  selectedImage: UIImage? = nil,
                                  group: NavigationGroup,
                                  handler: @escaping () -> Void,
                                  selectedHandler: @escaping () -> Bool) {
        let settingsButton = UIBarButtonItem(image: image,
                                             style: .plain,
                                             target: nil,
                                             action: nil)

        settingsButton.onTap { _ in
            handler()
            
            if selectedHandler() {
                settingsButton.image = (selectedImage ?? image)
            } else {
                settingsButton.image = image
            }
        }

        var items: [UIBarButtonItem] = (group == .left ?
                                        view.navigationItem.leftBarButtonItems :
                                            view.navigationItem.rightBarButtonItems) ?? [UIBarButtonItem]()

        items.append(settingsButton)

        if group == .left {
            view.navigationItem.leftBarButtonItems = items
        } else {
            view.navigationItem.rightBarButtonItems = items
        }
    }

    private func create() -> View {

        if let presenter = self as? View.Presenter {

            let viewController = View(presenter: presenter)
            view = viewController

            return viewController
        }

        fatalError("View type not valid!!")
    }

    deinit {
        debugPrint("DEINIT PRESENTER: \(String(describing: self))")
    }
}

public class MFMailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {

    let handler: () -> Void

    public init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    // MARK: MFMailComposeViewControllerDelegate

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            handler()
        }
        controller.dismiss(animated: true)
    }

}
