//
//  ColorAmbientLightViewController.swift
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

final class ColorAmbientLightViewController: DemoNodeNoViewController<ColorAmbientLightDelegate> {

    var containerLuxView = UIView()
    let luxView = ColorAmbientLightView()
    
    var containerCCTView = UIView()
    let cctView = ColorAmbientLightView()
    
    var containerUVIndexView = UIView()
    let uvIndexView = ColorAmbientLightView()
    
    let stackView = UIStackView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.colorAmbientLight.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        stackView.axis = .vertical
        stackView.spacing = 10.0

        view.addSubview(stackView, constraints: [
            equal(\.leadingAnchor, constant: 20.0),
            equal(\.trailingAnchor, constant: -20.0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])

        containerLuxView = luxView.embedInView(with: .standardEmbed)
        containerCCTView = cctView.embedInView(with: .standardEmbed)
        containerUVIndexView = uvIndexView.embedInView(with: .standardEmbed)

        stackView.addArrangedSubview(containerLuxView)
        stackView.addArrangedSubview(containerCCTView)
        stackView.addArrangedSubview(containerUVIndexView)
        stackView.addArrangedSubview(UIView())
        
        containerLuxView.isHidden = true
        containerCCTView.isHidden = true
        containerUVIndexView.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerLuxView.backgroundColor = .white
        containerLuxView.layer.cornerRadius = 8.0
        containerLuxView.applyShadow()

        containerCCTView.backgroundColor = .white
        containerCCTView.layer.cornerRadius = 8.0
        containerCCTView.applyShadow()
        
        containerUVIndexView.backgroundColor = .white
        containerUVIndexView.layer.cornerRadius = 8.0
        containerUVIndexView.applyShadow()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateColorAmbientLightUI(with: sample)
        }
    }
    
}
