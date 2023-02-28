//
//  GNSSFeatureViewController.swift
//  W2STApp

import Foundation
import BlueSTSDK
import MapKit

class GNSSFeatureViewController : BlueMSDemoTabViewController {
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var satellitesLabel: UILabel!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var btnShowMap: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    private var mGNSSFeature:BlueSTSDKFeatureGNSS?
    
    private var featureWasEnabled = false
    
    private var latitude: Float = 0.0
    private var longitude: Float = 0.0
    private var altitude: Float = 0.0
    
    @IBAction func showMapOnClick(_ sender: Any) {
        mapView.isHidden = false
        
        let point = MKPointAnnotation()

        let pointlatitude = Double(latitude)
        let pointlongitude = Double(longitude)
        point.title = "Last position"

        let coordinates = CLLocationCoordinate2DMake(pointlatitude ,pointlongitude)
        
        point.coordinate = coordinates
        mapView.addAnnotation(point)
        
        /**Center map on user location*/
        let mapCenter = coordinates
        let mapCamera = MKMapCamera(lookingAtCenter: mapCenter, fromEyeCoordinate: mapCenter, eyeAltitude: 3000)
        mapView.setCamera(mapCamera, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }

    public override func viewDidLoad() {
        super.viewDidLoad();
        
        btnShowMap.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public func startNotification(){
        mGNSSFeature = self.node.getFeatureOfType(BlueSTSDKFeatureGNSS.self) as? BlueSTSDKFeatureGNSS
        if let feature = mGNSSFeature{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    public func stopNotification(){
        if let feature = mGNSSFeature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }


    @objc func didEnterForeground() {
        mGNSSFeature = self.node.getFeatureOfType(BlueSTSDKFeatureGNSS.self) as? BlueSTSDKFeatureGNSS
        if !(mGNSSFeature==nil) && node.isEnableNotification(mGNSSFeature!) {
            featureWasEnabled = true
            stopNotification()
        }else {
            featureWasEnabled = false;
        }
    }
        
    @objc func didBecomeActivity() {
        if(featureWasEnabled) {
            startNotification()
        }
    }

}


extension GNSSFeatureViewController : BlueSTSDKFeatureDelegate{
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        mGNSSFeature = self.node.getFeatureOfType(BlueSTSDKFeatureGNSS.self) as? BlueSTSDKFeatureGNSS
        
        if let feature = mGNSSFeature{
            longitude = feature.getLongitudeValue(sample: sample) ?? 0.0
            latitude = feature.getLatitudeValue(sample: sample) ?? 0.0
            altitude = feature.getAltitudeValue(sample: sample) ?? 0.0
            
            DispatchQueue.main.async {
                self.latitudeLabel.text = self.latitude.description
                self.longitudeLabel.text = self.longitude.description
                self.altitudeLabel.text = self.altitude.description
        
                self.btnShowMap.isEnabled = true
            }
            
            let satellites = feature.getNSatValue(sample: sample)
            let signals = feature.getSigQualityValue(sample: sample)
            
            DispatchQueue.main.async {
                self.satellitesLabel.text = satellites?.description
                self.signalLabel.text = signals?.description
            }
        }
        
    }
    
}
