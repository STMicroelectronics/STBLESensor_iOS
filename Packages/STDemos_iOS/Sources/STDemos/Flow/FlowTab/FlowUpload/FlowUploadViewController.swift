//
//  FlowUploadViewController.swift
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
import STBlueSDK

final class FlowUploadViewController: BaseNoViewController<FlowUploadDelegate> {

    let flowNameLabel = UILabel()
    let flowSizeLabel = UILabel()
    
    let uploadButton = UIButton()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Upload"
        
        let uploadButton = UIButton()
        Buttonlayout.standard.apply(to: uploadButton, text: "UPLOAD")

        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(flowUploadButtonTapped(_:)))
        uploadButton.addGestureRecognizer(uploadTap)
        
        let mainSV = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            flowNameLabel,
            flowSizeLabel,
            uploadButton
        ])
        mainSV.distribution = .fill
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 16)
        ])
        scrollView.addSubview(mainSV, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
        
        presenter.load()
    }

    override func configureView() {
        super.configureView()
    }

}


extension FlowUploadViewController {
    @objc
    func flowUploadButtonTapped(_ sender: UITapGestureRecognizer) {
        presenter.askForUploadCurrentFlow()
    }
}

