//
//  FooterViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class FooterViewController: BaseViewController {
    
    var footerView: FooterView?
    
    var leftButton: UIButton? {
        return footerView?.leftButton
    }
    
    var rightButton: UIButton? {
        return footerView?.rightButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addFooter(to topView: UIView) {
        let footerView: FooterView = FooterView.createFromNib()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        var viewAnchor = view.bottomAnchor
        let topViewAnchor = topView.bottomAnchor
        
        if #available(iOS 11.0, *) {
            viewAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        
        for constrain in view.constraints {
            if (constrain.firstAnchor == viewAnchor && constrain.secondAnchor == topViewAnchor) || (constrain.secondAnchor == viewAnchor && constrain.firstAnchor == topViewAnchor) {
                view.removeConstraint(constrain)
            }
        }
        
        view.addSubview(footerView)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                footerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                footerView.topAnchor.constraint(equalTo: topView.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                footerView.topAnchor.constraint(equalTo: topView.bottomAnchor)
            ])
        }
        
        self.footerView = footerView
        self.footerView?.delegate = self
    }
    
    func createTitleLabel(with text: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.text = text
        return titleLabel.embedInView(with: UIEdgeInsets(top: 24.0, left: 0.0, bottom: 12.0, right: 0.0))
    }
}

extension FooterViewController: FooterDelegate {
    @objc
    func leftButtonPressed() {
        print("leftButton")
    }
    
    @objc
    func rightButtonPressed() {
        print("rightButton")
    }
    
}
