//
//  AccelerationEventViewController.swift
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

final class AccelerationEventViewController: DemoNodeNoViewController<AccelerationEventDelegate> {

    let accelerationTypeLabel = UILabel()
    let accelerationTypeBtn = UIButton()
    
    var containerAccEventSingleView = UIView()
    let accEventSingleView = AccEventSingleView()
    
    var containerAccEventMultipleView = UIView()
    let accEventMultipleView = AccEventMultipleView()
    
    var supportedEvents: [AccelerationEventCommand]?
    var mCurrentEvent = AccelerationEventCommand.multiple(enabled: false)
    var defaultEvent = AccelerationEventCommand.none
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.accelerationEvent.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        let description = UILabel()
        description.text = "Event:"
        TextLayout.title2.apply(to: description)
        description.textAlignment = .center
        
        accelerationTypeLabel.text = "None"
        accelerationTypeLabel.numberOfLines = 0
        TextLayout.info.apply(to: accelerationTypeLabel)
        
        accelerationTypeBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        accelerationTypeBtn.setTitle(" ", for: .normal)
        
        let accTypeSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            description,
            accelerationTypeLabel,
            accelerationTypeBtn,
        ])
        accTypeSV.distribution = .equalCentering
        
        containerAccEventSingleView = accEventSingleView.embedInView(with: .standard)
        containerAccEventMultipleView = accEventMultipleView.embedInView(with: .standardEmbed)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            accTypeSV,
            containerAccEventSingleView,
            containerAccEventMultipleView,
            UIView()
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        containerAccEventSingleView.isHidden = false
        containerAccEventMultipleView.isHidden = true
        
        supportedEvents = presenter.getSupportedEvents()
        defaultEvent = presenter.getDefaultEvent()
        
        presenter.updateRunningAccelerationEvent(defaultEvent)
        
        let changeAccelerationEventTap = UITapGestureRecognizer(target: self, action: #selector(changeAccelerationEventTapped(_:)))
        accelerationTypeBtn.addGestureRecognizer(changeAccelerationEventTap)
        
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateAccEventUI(with: sample)
        }
    }
}

extension AccelerationEventViewController {
    @objc
    func changeAccelerationEventTapped(_ sender: UITapGestureRecognizer) {
        presenter.changeAccelerationEvent()
    }
}
