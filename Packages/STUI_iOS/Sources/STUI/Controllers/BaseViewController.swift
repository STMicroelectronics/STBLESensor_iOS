//
//  BaseViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

protocol Childable: AnyObject {
    var isChild: Bool { get set }
}

open class BaseViewController<Presenter, View: UIView>: UIViewController, Childable, Presentable {
    
    public var presenter: Presenter!

    public var isChild: Bool = false

    public var mainView: View!
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    public required init(presenter: Presenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.configure()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(presenter: Presenter) {
        self.presenter = presenter
        self.configure()
    }
    
    open func configure() {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    open func makeView() -> View {
        View.make() as? View ?? View()
    }

    open func configureView() {
        let mainView = makeView()

        view.addSubview(mainView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.safeAreaLayoutGuide.leftAnchor),
            equal(\.safeAreaLayoutGuide.rightAnchor),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        self.mainView = mainView
        
        view.backgroundColor = mainView.backgroundColor
    }
    
    open func configureBackButton() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            
            let backButton = UIBarButtonItem(image: ImageLayout.Common.back?.template,
                                             style: .plain,
                                             target: self,
                                             action: #selector(backButtonTouched))
            
            backButton.tintColor = .white
            
            navigationItem.leftBarButtonItems = [backButton]
        }
    }
    
    @objc
        open func backButtonTouched() {
            self.navigationController?.popViewController(animated: true)
        }
    
    deinit {
        debugPrint("DEINIT CONTROLLER: \(String(describing: self))")
    }
    
}

open class BaseNoViewController<Presenter>: UIViewController, Presentable {

    public var presenter: Presenter!

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    open override var shouldAutorotate: Bool {
        return true
    }

    public required init(presenter: Presenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.configure()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override open func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(presenter: Presenter) {
        self.presenter = presenter
        self.configure()
    }

    open func configure() {

    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureBackButton()
    }

    open func configureView() {

    }

    open func configureBackButton() {
        if navigationController?.viewControllers.count ?? 0 > 1 {

            let backButton = UIBarButtonItem(image: ImageLayout.Common.back?.template,
                                             style: .plain,
                                             target: self,
                                             action: #selector(backButtonTouched))

            backButton.tintColor = .white

            navigationItem.leftBarButtonItems = [backButton]
        } else {
            navigationItem.leftBarButtonItems = []
        }
    }

    @objc
        open func backButtonTouched() {
            self.navigationController?.popViewController(animated: true)
        }

    deinit {
        debugPrint("DEINIT CONTROLLER: \(String(describing: self))")
    }

}

//public extension BaseNoViewController {
//    func showTabBar() {
//        guard let controller = parent?.parent as? TabBarViewController else { return }
//
//        controller.mainView.tabBarViewBottomConstraint.constant = 0.0
//        controller.mainView.mainViewOffsetConstraint.constant = -TabBarViewController.mainViewOffset
//
//        UIView.animate(withDuration: 0.3) {
//            controller.view.layoutIfNeeded()
//        }
//    }
//
//    func hideTabBar() {
//        guard let controller = parent?.parent as? TabBarViewController else { return }
//
//        controller.mainView.tabBarViewBottomConstraint.constant = -(controller.mainView.tabBarViewHeighConstraint.constant + UIDevice.current.safeAreaEdgeInsets.bottom)
//        controller.mainView.mainViewOffsetConstraint.constant = 0.0
//
//        UIView.animate(withDuration: 0.3) {
//            controller.view.layoutIfNeeded()
//        }
//    }
//}
