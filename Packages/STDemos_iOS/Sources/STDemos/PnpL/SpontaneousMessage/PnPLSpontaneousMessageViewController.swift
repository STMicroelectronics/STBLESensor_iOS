//
//  PnPLSpontaneousMessageViewController.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STCore

public class PnPLSpontaneousMessageViewController: BaseNoViewController<AlertDelegate> {

    let pnplSpontaneousMessageAlertView = PnPLSpontaneousMessageAlertView()
    let stackView = UIStackView()

    public override func configureView() {
        super.configureView()

        pnplSpontaneousMessageAlertView.translatesAutoresizingMaskIntoConstraints = false
        pnplSpontaneousMessageAlertView.layer.cornerRadius = 10
        pnplSpontaneousMessageAlertView.backgroundColor = .white
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(pnplSpontaneousMessageAlertView)

        NSLayoutConstraint.activate([
            pnplSpontaneousMessageAlertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pnplSpontaneousMessageAlertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pnplSpontaneousMessageAlertView.widthAnchor.constraint(equalToConstant: 280),
            pnplSpontaneousMessageAlertView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.load()
    }

}

extension PnPLSpontaneousMessageViewController {
    func configureView(with pnplSpontaneousMessageTypeAndDescription: PnPLSpontaneousMessageTypeAndDescription)  {
        let view = pnplSpontaneousMessageAlertView
        let pnplSpontaneousMessageType = pnplSpontaneousMessageTypeAndDescription.type
        let pnplSpontaneousMessageDescription = pnplSpontaneousMessageTypeAndDescription.description

        view.titleIcon.image = pnplSpontaneousMessageType.dialogIconImage
        
        view.titleLabel.text = pnplSpontaneousMessageType.title
        TextLayout.title2Colored(pnplSpontaneousMessageType.associatedColor).apply(to: view.titleLabel)
        
        view.descriptionLabel.text = pnplSpontaneousMessageDescription
        view.descriptionLabel.numberOfLines = 0
        view.descriptionLabel.textColor = pnplSpontaneousMessageType.associatedColor

        TextLayout.info
            .color(pnplSpontaneousMessageType.associatedColor)
            .apply(to: view.extraLabel)

        view.extraLabel.text = pnplSpontaneousMessageTypeAndDescription.extra

        Buttonlayout.smallLink
            .color(pnplSpontaneousMessageType.associatedColor)
            .apply(to: view.actionButton, text: pnplSpontaneousMessageTypeAndDescription.actionTitle)

        let isActionVisible = pnplSpontaneousMessageTypeAndDescription.extra != nil

        view.extraLabel.isHidden = !isActionVisible
        view.actionButton.isHidden = !isActionVisible

        Buttonlayout.standardColored(pnplSpontaneousMessageType.associatedColor).apply(to: view.dialogOkButton, text: "OK")
        
        pnplSpontaneousMessageAlertView.dialogOkButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }

        pnplSpontaneousMessageAlertView.actionButton.addAction(for: .touchUpInside) { _ in
            guard let navigator: Navigator = Resolver.shared.resolve(),
            let url = pnplSpontaneousMessageTypeAndDescription.url else { return }

            navigator.dismiss(animated: true) {
                navigator.open(url: url, presentationStyle: .fullScreen)
            }
        }
    }
}
