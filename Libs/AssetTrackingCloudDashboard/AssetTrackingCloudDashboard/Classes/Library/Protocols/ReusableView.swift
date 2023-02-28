//
//  ReusableView.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/10/2020.
//

import UIKit

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReusableView {}

extension UICollectionViewCell: ReusableView {}
