//
//  DemoGroupFilterViewController.swift
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
import TagListView

final class DemoGroupFilterViewController: BaseNoViewController<DemoGroupFilterDelegate> {

    let orderListView = TagListView()
    let tagListView = TagListView()

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "DemoGroupFilter_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        tagListView.alignment = .left

        tagListView.textFont = FontLayout.regular
        tagListView.tagSelectedBackgroundColor = ColorLayout.secondary.light
        tagListView.selectedBorderColor = ColorLayout.primary.light
        tagListView.selectedTextColor = ColorLayout.primary.light

        tagListView.tagBackgroundColor = .lightGray
        tagListView.borderColor = .darkGray.withAlphaComponent(0.5)
        tagListView.textColor = ColorLayout.primary.light

        tagListView.cornerRadius = 8.0
        tagListView.paddingX = 10.0
        tagListView.paddingY = 10.0
        tagListView.marginX = 10.0
        tagListView.marginY = 10.0

        orderListView.alignment = .left

        orderListView.textFont = FontLayout.regular
        orderListView.tagSelectedBackgroundColor = ColorLayout.secondary.light
        orderListView.selectedBorderColor = ColorLayout.primary.light
        orderListView.selectedTextColor = ColorLayout.primary.light

        orderListView.tagBackgroundColor = .lightGray
        orderListView.borderColor = .darkGray.withAlphaComponent(0.5)
        orderListView.textColor = ColorLayout.primary.light

        orderListView.cornerRadius = 8.0
        orderListView.paddingX = 10.0
        orderListView.paddingY = 10.0
        orderListView.marginX = 10.0
        orderListView.marginY = 10.0
        
        let cancelButton = UIButton(type: .custom)
        Buttonlayout.text.apply(to: cancelButton, text: Localizer.Common.cancel.localized)
        cancelButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.cancel()
        }

        let okButton = UIButton(type: .custom)
        Buttonlayout.standard.apply(to: okButton, text: Localizer.Common.ok.localized)
        okButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.done()
        }

        let buttonsStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                                  views: [
                                                                    cancelButton,
                                                                    okButton
                                                                  ])
        buttonsStackView.distribution = .fillEqually

        let orderingLabel = UILabel()
        TextLayout.title.apply(to: orderingLabel)
        orderingLabel.text =  "Ordering by"
        
        let filterLabel = UILabel()
        TextLayout.title.apply(to: filterLabel)
        filterLabel.text = Localizer.Catalog.Text.filters.localized

        let stackView = UIStackView.getVerticalStackView(withSpacing: 10.0,
                                                         views: [
                                                            orderingLabel,
                                                            orderListView,
                                                            filterLabel,
                                                            tagListView,
                                                            UIView(),
                                                            buttonsStackView
                                                         ])

        view.addSubview(stackView)
        stackView.addFitToSuperviewConstraints(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        buttonsStackView.setDimensionContraints(height: 60.0)
    }

}
