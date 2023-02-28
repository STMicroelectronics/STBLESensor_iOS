//
//  BaseTableViewCell.swift
//
//  Created by Dimitri Giani on 13/01/21.
//

import UIKit

open class BaseTableViewCell: UITableViewCell {
    public let containerView = UIView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }
    
    open func configureView() {
        contentView.addSubviewAndFit(containerView)
    }
    
    open func updateUI() {
        
    }
}
