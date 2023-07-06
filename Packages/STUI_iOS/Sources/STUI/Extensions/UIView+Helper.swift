//
//  UIView+Helper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension UIView {
    static func make<T>(with bundle: Bundle? = nil) -> T? where T: UIView {
        guard let view: T = self.viewFromNib(with: bundle) else {
            return nil
        }
        
        return view
    }
    
    private static func viewFromNib<T>(with bundle: Bundle? = nil) -> T? where T: UIView {
        
        var currentBundle: Bundle = Bundle(for: self)
    
        if let bundle = bundle {
            currentBundle = bundle
        }
        
        let viewName = String(String(describing: self).split(separator: ".").last ?? Substring(String(describing: self)))
        
        return currentBundle.loadNibNamed(viewName,
                                          owner: nil,
                                          options: nil)?.first as? T
    }
    
    func clear() {
        backgroundColor = .clear
        
        for view in subviews {
            view.clear()
        }
    }
    
    func embedInView(with insets: UIEdgeInsets) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.addSubview(self, constraints: [
            equal(\.topAnchor, constant: insets.top),
            equal(\.leftAnchor, constant: insets.left),
            equal(\.rightAnchor, constant: -insets.right),
            equal(\.bottomAnchor, constant: -insets.bottom)
        ])
        
        return container
    }

    class func empty(with color: UIColor = .white, width: CGFloat? = nil, height: CGFloat? = nil) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.setDimensionContraints(width: width, height: height)

        return view
    }
}
