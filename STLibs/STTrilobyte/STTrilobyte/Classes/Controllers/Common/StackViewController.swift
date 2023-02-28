//
//  StackViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 19/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class StackViewController: FooterViewController {

    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var stackView: UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.autoAnchorToSuperViewSafeArea()
        stackView.autoAnchorToSuperView()
        
        stackView.axis = .vertical
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
    }
}
