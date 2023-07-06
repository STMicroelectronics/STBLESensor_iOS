//
//  EventCounterViewController.swift
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

final class EventCounterViewController: DemoNodeNoViewController<EventCounterDelegate> {

    let stackView = UIStackView()
    
    let eventCounterTitle = UILabel()
    let eventCounterLabel = UILabel()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.eventCounter.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        stackView.axis = .vertical
        stackView.spacing = 16.0
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        view.addSubview(stackView, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        eventCounterTitle.text =  "# Events"
        eventCounterTitle.font = .preferredFont(forTextStyle: .largeTitle)
        eventCounterTitle.textAlignment = .center
        
        eventCounterLabel.text =  "0"
        eventCounterLabel.font = .boldSystemFont(ofSize: 120)
        eventCounterLabel.textAlignment = .center
        
        stackView.addArrangedSubview(eventCounterTitle)
        stackView.addArrangedSubview(eventCounterLabel)
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in

            self?.presenter.updateCounter(with: sample)
        }
    }

}
