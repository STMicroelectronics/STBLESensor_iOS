//
//  TabBarController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class TabBarController<Presenter>: UITabBarController, Presentable {
    
    public typealias View = UIView
    
    public var presenter: Presenter!
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
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(presenter: Presenter) {
        self.presenter = presenter
        self.configure()
    }
    
    deinit {
        debugPrint("DEINIT CONTROLLER: \(String(describing: self))")
    }
    
    open func configure() {
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
