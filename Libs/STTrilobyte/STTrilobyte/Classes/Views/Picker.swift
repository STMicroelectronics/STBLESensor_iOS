//
//  Picker.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 12/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol Pickable {
    func displayName() -> String
}

class Picker: UIView {

    private lazy var titleLabel: UILabel = UILabel(frame: .zero)
    private lazy var actionButton: UIButton = UIButton()
    private lazy var pickerView: UIPickerView = UIPickerView()
    private lazy var dummyTextField: UITextField = UITextField(frame: .zero)

    private var completionHandler: ((Pickable) -> Void)?

    var active: Bool {
        set(active) {
            actionButton.isEnabled = active
        }
        get {
            return actionButton.isEnabled
        }
    }

    var selectedItem: Pickable? {
        didSet {
            if let selectedItem = selectedItem {
                actionButton.setTitle(selectedItem.displayName(), for: .normal)
            } else {
                actionButton.setTitle("-", for: .normal)
            }

            dummyTextField.text = selectedItem?.displayName()
        }
    }
    var items: [Pickable] = [Pickable]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureView()
    }

//    func configure(items: [Pickable], selected: Pickable?) {
//        self.items = items
//        self.selectedItem = selected
//
//        var selectedItemIndex = 0
//        if let selected = selectedItem, let index = items.firstIndex(where: { $0.displayName() == selected.displayName() }) {
//            selectedItemIndex = index
//        }
//
//        pickerView.selectRow(selectedItemIndex, inComponent: 0, animated: true)
//    }

    func configure(title: String, items: [Pickable], selected: Pickable?, completionHandler: @escaping (Pickable) -> Void) {
        titleLabel.text = title

        self.items = items
        self.selectedItem = selected

        var selectedItemIndex = 0
        if let selected = selectedItem, let index = items.firstIndex(where: { $0.displayName() == selected.displayName() }) {
            selectedItemIndex = index
        }

        pickerView.selectRow(selectedItemIndex, inComponent: 0, animated: true)

        self.completionHandler = completionHandler
    }

    @objc
    func actionButtonPressed() {
        dummyTextField.becomeFirstResponder()
    }

    @objc
    func doneButtonPressed() {
        dummyTextField.resignFirstResponder()

        if let completionHandler = completionHandler, let selectedItem = selectedItem {
            completionHandler(selectedItem)
        }
    }
}

private extension Picker {
    func configureView() {

        titleLabel.font = currentTheme.font.regular.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.text = "Label"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        actionButton.titleLabel?.numberOfLines = 1
        actionButton.contentHorizontalAlignment = .left
        actionButton.titleLabel?.textAlignment = .left
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        addSubview(actionButton)

        let arrowImage = UIImageView(image: UIImage.named("img_dropdown"))
        arrowImage.tintColor = currentTheme.color.secondary
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowImage)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionButton.leftAnchor.constraint(equalTo: leftAnchor),
            actionButton.rightAnchor.constraint(equalTo: rightAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 50.0),
            arrowImage.rightAnchor.constraint(equalTo: actionButton.rightAnchor),
            arrowImage.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            arrowImage.heightAnchor.constraint(equalToConstant: 24.0),
            arrowImage.widthAnchor.constraint(equalToConstant: 24.0)
        ])

        addDoneButton()

        pickerView.delegate = self
        pickerView.dataSource = self
    }

    func addDoneButton() {
        dummyTextField.inputView = pickerView
        dummyTextField.isHidden = true
        addSubview(dummyTextField)

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(doneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dummyTextField.inputAccessoryView = toolBar
    }
}

extension Picker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].displayName()
    }
}

extension Picker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = items[row]
    }

}
