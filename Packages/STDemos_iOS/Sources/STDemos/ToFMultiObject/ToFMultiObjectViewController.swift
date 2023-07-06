//
//  ToFMultiObjectViewController.swift
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

final class ToFMultiObjectViewController: DemoNodeNoViewController<ToFMultiObjectDelegate> {
    
    var isPresenceDetectionModeActivated = false
    
    var containerPresenceView = UIView()
    let presenceView = ToFPresenceView()
    
    var containerObjectView = UIView()
    let objectView = ToFObjectView()
    
    var containerDistance1View = UIView()
    let distance1View = ToFDistanceView()
    
    var containerDistance2View = UIView()
    let distance2View = ToFDistanceView()
    
    var containerDistance3View = UIView()
    let distance3View = ToFDistanceView()
    
    var containerDistance4View = UIView()
    let distance4View = ToFDistanceView()
    
    let selector = UISwitch()
        
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.tofMultiObject.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        let description = UILabel()
        description.text = "Use the switch to change detection type"
        TextLayout.info.apply(to: description)
        description.textAlignment = .center
        
        let objectDistanceLabel = UILabel()
        objectDistanceLabel.text = "Object"
        TextLayout.info.apply(to: objectDistanceLabel)
        
        let personPresenceLabel = UILabel()
        personPresenceLabel.text = "Presence"
        TextLayout.info.apply(to: personPresenceLabel)
        
        selector.isOn = false
        selector.addTarget(self, action: #selector(switchModeBtnTapped), for: .valueChanged)
        containerPresenceView.isHidden = true
        
        let selectorSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            UIView(),
            objectDistanceLabel,
            selector,
            personPresenceLabel,
            UIView()
        ])
        selectorSV.distribution = .fillEqually
        
        containerPresenceView = presenceView.embedInView(with: .standard)
        containerObjectView = objectView.embedInView(with: .standardEmbed)
        containerDistance1View = distance1View.embedInView(with: .standardEmbed)
        containerDistance2View = distance2View.embedInView(with: .standardEmbed)
        containerDistance3View = distance3View.embedInView(with: .standardEmbed)
        containerDistance4View = distance4View.embedInView(with: .standardEmbed)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            description,
            selectorSV,
            containerPresenceView,
            containerObjectView,
            containerDistance1View,
            containerDistance2View,
            containerDistance3View,
            containerDistance4View
        ])
        mainStackView.distribution = .fill
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
        
        containerPresenceView.isHidden = true
        containerObjectView.isHidden = true
        containerDistance1View.isHidden = true
        containerDistance2View.isHidden = true
        containerDistance3View.isHidden = true
        containerDistance4View.isHidden = true
        
        let userDefaults = UserDefaults.standard
        isPresenceDetectionModeActivated = userDefaults.bool(forKey: "isPresenceDetectionModeActivated")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerPresenceView.backgroundColor = .white
        containerPresenceView.layer.cornerRadius = 8.0
        containerPresenceView.applyShadow()
        
        containerObjectView.backgroundColor = .white
        containerObjectView.layer.cornerRadius = 8.0
        containerObjectView.applyShadow()

        containerDistance1View.backgroundColor = .white
        containerDistance1View.layer.cornerRadius = 8.0
        containerDistance1View.applyShadow()
        
        containerDistance2View.backgroundColor = .white
        containerDistance2View.layer.cornerRadius = 8.0
        containerDistance2View.applyShadow()
        
        containerDistance3View.backgroundColor = .white
        containerDistance3View.layer.cornerRadius = 8.0
        containerDistance3View.applyShadow()
        
        containerDistance4View.backgroundColor = .white
        containerDistance4View.layer.cornerRadius = 8.0
        containerDistance4View.applyShadow()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateToFUI(with: sample)
        }
    }

}

extension ToFMultiObjectViewController {
    @objc
    func switchModeBtnTapped(_ sender: UISwitch) {
        presenter.switchMode()
    }
}
