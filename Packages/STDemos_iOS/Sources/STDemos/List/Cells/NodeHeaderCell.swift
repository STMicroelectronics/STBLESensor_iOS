//
//  NodeHeaderCell.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class NodeHeaderCell: BaseTableViewCell {

    let containerView = UIView()

    let nodeImageView = UIImageView()
    let nodeTextLabel = UILabel()
    //let nodeDetailTextLabel = UILabel()
    let divisor = UIView()
    let nodeExtraTextLabel = UILabel()
    
    let customDtmiLabel = PaddingLabel()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerView)
        containerView.addFitToSuperviewConstraints(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)

        nodeImageView.setDimensionContraints(height: 120.0)

        divisor.backgroundColor = ColorLayout.stGray5.light
        divisor.setDimensionContraints(height: 1)
        divisor.isHidden = true
        
        customDtmiLabel.text = "Custom DTMI"
        customDtmiLabel.isHidden = true
        TextLayout.info.color(ColorLayout.accent.light).apply(to: customDtmiLabel)
        
        let stackView = UIStackView.getVerticalStackView(withSpacing: 10,
                                                         views: [
                                                            nodeTextLabel.embedInView(with: .standard.top(10.0)),
                                                            //nodeDetailTextLabel.embedInView(with: .standard),
                                                            nodeImageView,
                                                            divisor,
                                                            nodeExtraTextLabel.embedInView(with: .standard.bottom(10.0)),
                                                            customDtmiLabel
                                                         ])

        containerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8.0
        containerView.applyShadow()
    }
}

@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 10.0
    @IBInspectable var leftInset: CGFloat = 20.0
    @IBInspectable var rightInset: CGFloat = 20.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + leftInset + rightInset,
            height: size.height + topInset + bottomInset
        )
    }
}
