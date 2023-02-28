//
//  UIKit+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

extension UIView {
    
    // swiftlint:disable force_cast
    static func createFromNib<T>() -> T {
        let string = String(describing: T.self)
        let bundle = Bundle.current()
        return bundle.loadNibNamed(string, owner: self, options: nil)?.first as! T
    }
    // swiftlint:enable force_cast
    
    func embedInView(with insets: UIEdgeInsets) -> UIView {
        
        translatesAutoresizingMaskIntoConstraints = false
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(self)
        
        NSLayoutConstraint.activate([ leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left),
                                      rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right),
                                      topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
                                      bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom) ])
        
        return container
    }
}
