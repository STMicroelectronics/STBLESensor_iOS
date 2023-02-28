//
//  UIView+Layout.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

extension UIView {
    
    func autoAnchorToSuperView(with insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left),
                                      rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -insets.right),
                                      topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                                      bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom) ])
    }
    
    func autoAnchorToSuperViewSafeArea(with insets: UIEdgeInsets = .zero) {
        
        if #available(iOS 11.0, *) {
            guard let superview = superview else { return }
            
            translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([ leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor, constant: insets.left),
                                          rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor, constant: -insets.right),
                                          topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                                          bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom) ])
        } else {
            self.autoAnchorToSuperView()
        }
        
    }
    
}
