//
//  HeaderLabelView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class HeaderLabelViewModel: BaseViewModel<CodeValue<String>, HeaderLabelView> {

    private var image: UIImage?

    public init(param: CodeValue<String>?,
                layout: Layout? = nil,
                image: UIImage? = nil) {
        self.image = image
        super.init(param: param, layout: layout)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: HeaderLabelView) {
        view.headerLabelImageView.image = image
        view.headerLabelTextLabel.text = param?.value
        

//        view.actionImageView.contentMode = .center
//
//        view.actionImageView.image = image

        if let layout = layout {
            layout.textLayout?.apply(to: view.headerLabelTextLabel)
        }
    }

    public override func update(view: HeaderLabelView, values: [any KeyValue]) {

        guard let values = values.filter({ $0 is CodeValue<String> }) as? [CodeValue<String>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
        view.headerLabelTextLabel.text = param?.value
    }

}

open class HeaderLabelView: UIView {
    let headerLabelImageView = UIImageView()
    let headerLabelTextLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        headerLabelImageView.setDimensionContraints(width: 40.0, height: 40.0)
        
        let stackView = UIStackView.getHorizontalStackView(withSpacing: 8.0, views: [
            headerLabelImageView,
            headerLabelTextLabel
        ])

        headerLabelTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        addSubviewAndFit(stackView)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
