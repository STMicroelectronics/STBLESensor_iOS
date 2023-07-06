//
//  ImageDetailViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class ImageDetail {
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?

    public init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}

public class ImageDetailViewModel: BaseViewModel<CodeValue<ImageDetail>, ImageDetailView> {

    public var childViewModel: (any ViewViewModel)?

    public override func configure(view: ImageDetailView) {

        if let layout = layout {
            layout.titleLayout?.apply(to: view.titleLabel)
            layout.textLayout?.apply(to: view.subtitleLabel)
        }

        view.imageView.contentMode = .scaleAspectFit

        view.titleLabel.text = param?.value.title
        view.subtitleLabel.text = param?.value.subtitle
        view.imageView.image = param?.value.image

        if let chilView = view.childView {
            view.horizzontalStackView.removeArrangedSubview(chilView)
            view.childView = nil
        }

        if let childViewModel = childViewModel {
            let currentView = childViewModel.make()
            view.horizzontalStackView.addArrangedSubview(currentView)
            view.childView = currentView

            childViewModel.configure(view: currentView)
        }
    }

    public override func update(view: ImageDetailView, values: [any KeyValue]) {

        if let childViewModel = childViewModel,
           let childView = view.childView {
            childViewModel.update(view: childView, values: values)
        }

        guard let values = values.filter({ $0 is CodeValue<ImageDetail> }) as? [CodeValue<ImageDetail>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
        view.titleLabel.text = param?.value.title
        view.subtitleLabel.text = param?.value.subtitle
    }

    public override func update(with values: [any KeyValue]) {

        if let childViewModel = childViewModel {
            childViewModel.update(with: values)
        }

        guard let values = values.filter({ $0 is CodeValue<ImageDetail> }) as? [CodeValue<ImageDetail>],
            let value = values.first(where: { $0 == param}) else { return }

        param?.value = value.value
    }
}
