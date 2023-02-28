//
//  UITableViewCell+Extensions.swift
//
//  Created by Dimitri Giani on 13/01/21.
//

import UIKit

public extension UITableViewCell
{
    var cellActionButtonLabel: UILabel? {
        superview?.subviews
            .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
            .flatMap { $0.subviews }
            .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }.first
    }
    
    static func dequeueNib(withClassName className: String, from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    {
        let nib = UINib(nibName: className, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: className)
        
        return tableView.dequeueReusableCell(withIdentifier: className, for: indexPath)
    }
    
    static func dequeueNib<T:UITableViewCell>(from tableView: UITableView, at indexPath: IndexPath) -> T
    {
        let identifier = String(describing: T.self)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
        
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
    
    static func dequeue<T:UITableViewCell>(from tableView: UITableView, at indexPath: IndexPath) -> T
    {
        let identifier = String(describing: T.self)
        tableView.register(T.self, forCellReuseIdentifier: identifier)
        
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}
