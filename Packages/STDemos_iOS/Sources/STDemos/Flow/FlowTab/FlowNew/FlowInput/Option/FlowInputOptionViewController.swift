//
//  FlowInputOptionViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

final class FlowInputOptionViewController: BaseNoViewController<FlowInputOptionDelegate> {

    var stackView = UIStackView()
    var bottomView: UIStackView?

    let regConfigView: RegConfigView = RegConfigView.createFromNib()
    
    let odrPicker: Picker = Picker()
    let customOdrStackView: UIStackView = UIStackView()
    let customOdrCheckBoxRow: CheckBoxRow = CheckBoxRow.createFromNib()
    let customOdrTextField = TextField()
    let customOdrMinLabel = UILabel()
    let lowPassPicker: Picker = Picker()
    let highPassPicker: Picker = Picker()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton(type: .custom)
        let cancelButton = UIButton(type: .custom)
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.done?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: doneButton, text: "DONE")
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.close?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: cancelButton, text: "CANCEL")
        
        doneButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.doneButtonTapped()
        }
        
        cancelButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.cancelButtonTapped()
        }
        
        let buttonStackView = UIStackView.getHorizontalStackView(
            withSpacing: 10.0,
            views: [
                cancelButton.embedInView(with: .standardEmbed),
                doneButton.embedInView(with: .standardEmbed)
            ]
        )
        buttonStackView.distribution = .fillEqually
        
        var bottomViews = [UIView]()
        bottomViews.append(buttonStackView)

        if UIDevice.current.hasNotch {
            bottomViews.append(UIView.empty(height: 40.0))
        }

        let bottomStackView = UIStackView.getVerticalStackView(withSpacing: 0.0,
                                                               views: bottomViews)

        bottomViews.forEach { view in
            view.backgroundColor = ColorLayout.primary.light
        }
        
        view.addSubview(bottomStackView)
        bottomStackView.activate(constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        bottomView = bottomStackView
        
        stackView.axis = .vertical
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])

        regConfigView.delegate = self
        
        presenter.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bottomView = bottomView else { return }

        view.bringSubviewToFront(bottomView)
        bottomView.applyShadow()
    }
    
    override func configureView() {
        super.configureView()
    }

}

extension FlowInputOptionViewController: RegConfigViewDelegate, UIDocumentPickerDelegate {
    func ucfPickerUserRequestFile() {
        let ucfPicker = UIDocumentPickerViewController(documentTypes: ["com.st.bluems.document.ucf"], in: .import)
        ucfPicker.delegate = self
        present(ucfPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
        if let selectedFile = urls.first{
            regConfigView.parseUcfFile(ucf: selectedFile)
        }
    }
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){
        regConfigView.parseUcfFile(ucf: url)
    }
}

extension UIView {
    static func createFromNib<T>() -> T {
        let string = String(describing: T.self)
        let bundle = Bundle.module
        return bundle.loadNibNamed(string, owner: self, options: nil)?.first as! T
    }
}
