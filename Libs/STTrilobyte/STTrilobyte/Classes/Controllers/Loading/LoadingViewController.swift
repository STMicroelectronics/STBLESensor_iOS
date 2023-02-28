//
//  LoadingViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 23/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var text: String = ""
    var message: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        loadingLabel.font = currentTheme.font.regular.withSize(14.0)

        titleLabel.text = text
        loadingLabel.text = message
    }
    
    func configure(with text: String, message: String) {
        self.text = text
        self.message = message
    }

}
