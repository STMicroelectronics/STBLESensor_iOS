//
//  BaseSubtitleCell.swift
//
//  Created by Dimitri Giani on 30/04/21.
//

import UIKit

public class BaseSubtitleCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
