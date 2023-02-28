//
//  AddFunctionButton.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 09/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol AddFunctionButtonDelegate: class {
    func didPressAddFunctionButton()
}

class AddFunctionButtonView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!

    weak var delegate: AddFunctionButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        guard let delegate = delegate else { return }

        delegate.didPressAddFunctionButton()
    }
}

private extension AddFunctionButtonView {

    func configureView() {

        addButton.applyStyle(.border(insets: .zero, cornerRadius: 2.0, height: 1.0),
                             fillColor: nil,
                             strokeColor: currentTheme.color.cardSecondary,
                             overlay: true)

        addButton.backgroundColor = currentTheme.color.cardPrimary

        addButton.titleLabel?.font = currentTheme.font.regular.withSize(16.0)
        addButton.setTitleColor(currentTheme.color.text, for: .normal)
        addButton.tintColor = currentTheme.color.text

        addButton.setTitle("flow_add_function".localized().uppercased(), for: .normal)
        addButton.setImage(UIImage.named("img_add"), for: .normal)

        bottomView.backgroundColor = currentTheme.color.cardSecondary
    }

}
