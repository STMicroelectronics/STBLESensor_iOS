//
//  TitleIconView.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 12/01/21.
//

import UIKit

public class TitleIconView: BaseView {
    public let label = UILabel()
    public let icon = UIImageView()
    public let stackView = UIStackView()
    
    public override func configureView() {
        super.configureView()
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(icon)
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        setDimensionContraints(width: 60, height: nil)
        
        icon.setDimensionContraints(width: 16, height: 16)
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        addSubviewAndFit(stackView)
    }
}
