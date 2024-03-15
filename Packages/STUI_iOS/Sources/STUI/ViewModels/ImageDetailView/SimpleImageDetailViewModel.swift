//
//  SimpleImageDetailViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class SimpleImageDetailViewModel: BaseViewModel<CodeValue<ImageDetail>, SimpleImageDetailView> {

    public var childViewModel: (any ViewViewModel)?

    public override func configure(view: SimpleImageDetailView) {

        if let layout = layout {
            layout.titleLayout?.apply(to: view.titleLabel)
            layout.textLayout?.apply(to: view.subtitleLabel)
        }

        view.imageView.contentMode = .center

        view.titleLabel.isHidden = param?.value.title?.count == 0
        view.subtitleLabel.isHidden = param?.value.subtitle?.count == 0

        view.titleLabel.text = param?.value.title
        view.subtitleLabel.text = param?.value.subtitle
        view.imageView.image = param?.value.image?.withTintColor(ColorLayout.primary.light)
            .scalePreservingAspectRatio(targetSize: ImageSize.medium).original
    }

    public override func update(view: SimpleImageDetailView, values: [any KeyValue]) {

        guard let values = values.filter({ $0 is CodeValue<ImageDetail> }) as? [CodeValue<ImageDetail>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
        view.titleLabel.text = param?.value.title
        view.subtitleLabel.text = param?.value.subtitle

        view.titleLabel.isHidden = param?.value.title?.count == 0
        view.subtitleLabel.isHidden = param?.value.subtitle?.count == 0
    }

    public override func update(with values: [any KeyValue]) {

        guard let values = values.filter({ $0 is CodeValue<ImageDetail> }) as? [CodeValue<ImageDetail>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
    }
}
