//
//  UICollectionView+Helper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit

public extension UICollectionView {
    
    var currentPage: Int {
        
        frame.width == 0.0 ? 0 : Int(round(contentOffset.x / frame.width))
    }
    
    func registerCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reusableIdentifier)
    }
    
    func registerNibCell<T: UICollectionViewCell>(_ cell: T.Type, bundle: Bundle) {
        register(UINib(nibName: cell.reusableIdentifier, bundle: bundle), forCellWithReuseIdentifier: cell.reusableIdentifier)
    }
}

public extension UICollectionViewCell {
    static var reusableIdentifier: String {
        String(describing: self)
    }
}
