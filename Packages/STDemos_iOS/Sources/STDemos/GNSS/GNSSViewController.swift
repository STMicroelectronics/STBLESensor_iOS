//
//  GNSSViewController.swift
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
import MapKit

final class GNSSViewController: DemoNodeNoViewController<GNSSDelegate> {

    var containerCoordinatesView = UIView()
    let coordinatesView = GNSSCoordinatesView()
    
    var containterSatellitesView = UIView()
    let satellitesView = GNSSSatellitesView()
    
    let showMap = UIButton()
    
    let mapView : MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .dark
        return map
    }()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.gnss.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        let title = UILabel()
        title.text = "Global Navigation Satellite"
        TextLayout.title.apply(to: title)
        title.textAlignment = .center
        
        containerCoordinatesView = coordinatesView.embedInView(with: .standard)
        containterSatellitesView = satellitesView.embedInView(with: .standardEmbed)
        
        Buttonlayout.standard.apply(to: showMap, text: "Show Map")
        showMap.isEnabled = false
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.setDimensionContraints(height: 300)
        
        mapView.isHidden = true
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            title,
            containerCoordinatesView,
            containterSatellitesView,
            showMap,
            mapView
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
        
        let showMapTap = UITapGestureRecognizer(target: self, action: #selector(showMapBtnTapped(_:)))
        showMap.addGestureRecognizer(showMapTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerCoordinatesView.backgroundColor = .white
        containerCoordinatesView.layer.cornerRadius = 8.0
        containerCoordinatesView.applyShadow()
        
        containterSatellitesView.backgroundColor = .white
        containterSatellitesView.layer.cornerRadius = 8.0
        containterSatellitesView.applyShadow()
    }
    
    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        
        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateGNSSUI(with: sample)
        }
    }
}

extension GNSSViewController {
    @objc
    func showMapBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.showMap()
    }
}

