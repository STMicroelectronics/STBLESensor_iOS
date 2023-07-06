//
//  GNSSPresenter.swift
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

final class GNSSPresenter: DemoPresenter<GNSSViewController> {
    private var latitude: Float = 0.0
    private var longitude: Float = 0.0
    private var altitude: Float = 0.0
}

// MARK: - GNSSViewControllerDelegate
extension GNSSPresenter: GNSSDelegate {

    func load() {
        
        demo = .gnss
        
        demoFeatures = param.node.characteristics.features(with: Demo.gnss.features)
        
        view.configureView()
    }
    
    func updateGNSSUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<GNSSData>,
           let data = sample.data {
            
            latitude = data.latitude.value ?? 0.0
            longitude = data.longitude.value ?? 0.0
            altitude = data.altitude.value ?? 0.0
            
            let satellites = data.numberOfSatellites.value
            let signal = data.qualityOfSignal.value
            
            view.coordinatesView.latitude.text = "\(latitude.description) [N]"
            view.coordinatesView.longitude.text = "\(longitude.description) [E]"
            view.coordinatesView.altitude.text = "\(altitude.description) [m]"
            
            view.satellitesView.satellites.text = "\(satellites?.description ?? "0") [Num]"
            view.satellitesView.satellites.text = "\(signal?.description ?? "0") [dB-Hz]"
            
            view.showMap.isEnabled = true
        }
    }
    
    func showMap() {
        view.mapView.isHidden = false
        
        let point = MKPointAnnotation()

        let pointlatitude = Double(latitude)
        let pointlongitude = Double(longitude)
        point.title = "Last position"

        let coordinates = CLLocationCoordinate2DMake(pointlatitude ,pointlongitude)
        
        point.coordinate = coordinates
        view.mapView.addAnnotation(point)
        
        /**Center map on user location*/
        let mapCenter = coordinates
        let mapCamera = MKMapCamera(lookingAtCenter: mapCenter, fromEyeCoordinate: mapCenter, eyeAltitude: 3000)
        view.mapView.setCamera(mapCamera, animated: true)
    }

}
