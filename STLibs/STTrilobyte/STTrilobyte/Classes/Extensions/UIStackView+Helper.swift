//
//  UIStackView+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 29/03/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Remove the views from self
        removedSubviews.forEach { $0.removeFromSuperview() }
    }
}
