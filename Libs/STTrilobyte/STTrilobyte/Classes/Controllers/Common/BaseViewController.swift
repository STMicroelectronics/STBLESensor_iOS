//
//  BaseController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import STTheme

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = currentTheme.color.background
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(currentTheme.color.navigationBar), for: .default)
        navigationController?.navigationBar.tintColor = currentTheme.color.navigationBarText
        navigationController?.navigationBar.backIndicatorImage = UIImage.named("img_back")?.withRenderingMode(.alwaysTemplate)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage.named("img_back")?.withRenderingMode(.alwaysTemplate)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
        
        if let nav = navigationController, !nav.viewControllers.isEmpty {
            let item = UIBarButtonItem(image: UIImage.named("img_back")?.withRenderingMode(.alwaysTemplate),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonPressed))
            
            navigationItem.leftBarButtonItems = [item]
        }
    }
    
    @objc
    func backButtonPressed() {
        
        if navigationController?.viewControllers.count == 1 {
            tabBarController?.navigationController?.popViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
