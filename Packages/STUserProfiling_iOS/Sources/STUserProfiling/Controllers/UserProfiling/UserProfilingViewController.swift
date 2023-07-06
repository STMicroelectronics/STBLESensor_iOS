//
//  UserProfilingViewController.swift
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

public final class UserProfilingViewController: BaseProfilingViewController<UserProfilingDelegate, UserProfilingView> {
    
    public override func configure() {
        super.configure()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = "AppType_title"
        
        presenter.load()
    }
    
    override public func configureBackButton() {
        
        if navigationController?.viewControllers.filter({ controller in
            type(of: controller) == UserProfilingViewController.self
        }).count ?? 0 > 1 {
            let backButton = UIBarButtonItem(image: UIImage(named: "img_back",
                                                            in: STUI.bundle,
                                                            compatibleWith: nil)?.template,
                                             style: .plain,
                                             target: self,
                                             action: #selector(backButtonTouched))
            
            backButton.tintColor = ColorLayout.primary.dark
            
            navigationItem.leftBarButtonItems = [backButton]
        }
    }
    
    public override func configureView() {
        super.configureView()
        
        mainView.nextButton.addTarget(self, action: #selector(nextButtonTouched(_:)), for: .touchUpInside)
    }
    
}

private extension UserProfilingViewController {
    
    @objc
    func nextButtonTouched(_ sender: Any?)  {
        self.presenter.didTouchNextButton()
    }
    
}
