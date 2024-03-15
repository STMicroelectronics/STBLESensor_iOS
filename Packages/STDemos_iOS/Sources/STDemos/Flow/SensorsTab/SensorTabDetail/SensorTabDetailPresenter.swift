//
//  SensorTabDetailPresenter.swift
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

final class SensorTabDetailPresenter: BasePresenter<SensorTabDetailViewController, Sensor> {

}

// MARK: - SensorTabDetailViewControllerDelegate
extension SensorTabDetailPresenter: SensorTabDetailDelegate {

    func load() {
        view.configureView()
        
        let icon = UIImageView()
        icon.image = param.sensorIconToImage(icon: param.icon)
        icon.setDimensionContraints(width: 40.0)
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let name = UILabel()
        name.text = param.descr
        TextLayout.title.apply(to: name)
        name.numberOfLines = 0
        name.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        let headerSV = UIStackView.getHorizontalStackView(withSpacing: 24, views: [
            icon,
            name
        ])
        
        var sViews: [UIStackView] = []
        
        sViews.append(headerSV)
        
        sViews.append(buildRow("Output", param.output))
        if param.uom != nil && param.uom != "" {
           sViews.append(buildRow("Unit", param.uom ?? "-"))
        }
        if param.description != "-" {
            sViews.append(buildRow("Properties", param.description))
        }
        if param.notes != nil && param.notes != "" {
            sViews.append(buildRow("Description", param.notes ?? "-"))
        }
        sViews.append(buildRow("Model", param.model))
        
        let dataSheetRow = buildRow("DataSheet", "open from www.st.com", clickable: true)
        dataSheetRow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dataSheetSVClicked)))
        sViews.append(dataSheetRow)
        
        let mainSV = UIStackView.getVerticalStackView(withSpacing: 24, views: sViews)
        
        view.view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.view.addSubview(scrollView, constraints: [
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
    }

    private func buildRow(_ label: String, _ value: String, clickable: Bool = false) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.numberOfLines = 0
        TextLayout.infoBold.apply(to: titleLabel)
        
        let valueLabel = UILabel()
        TextLayout.info.apply(to: valueLabel)

        if clickable {
            valueLabel.attributedText = NSAttributedString(string: value, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
        } else {
            valueLabel.text = value
        }

        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .left
        
        titleLabel.setDimensionContraints(width: 90)
        
        let sv = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            titleLabel,
            valueLabel
        ])

        sv.distribution = .fill
        
        return sv
    }
    
    @objc func dataSheetSVClicked() {
        if let uriString = param.datasheetLink {
            if let url = URL(string: uriString) {
                UIApplication.shared.open(url)
            }
        }
    }
}
