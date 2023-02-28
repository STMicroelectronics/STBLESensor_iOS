//
//  ColorAmbientLightViewController.swift
//  W2STApp

import Foundation
import BlueSTSDK

class ColorAmbientLightViewController : BlueMSDemoTabViewController {
    
    
    @IBOutlet weak var textViewLux: UILabel!
    @IBOutlet weak var progressBarLux: UIProgressView!
    
    @IBOutlet weak var textViewCCT: UILabel!
    @IBOutlet weak var progressBarCCT: UIProgressView!
    
    @IBOutlet weak var textViewUVIndex: UILabel!
    @IBOutlet weak var progressBarUVIndex: UIProgressView!
    
    public let DATA_MAX_LUX: Int = 400000
    public let DATA_MIN_LUX: Int = 0
    
    public let DATA_MAX_UV_INDEX: Int = 12
    public let DATA_MIN_UV_INDEX: Int = 0
    
    public let DATA_MAX_CCT: Int = 20000
    public let DATA_MIN_CCT: Int = 0
    
    private var mColorAmbientLightFeature:BlueSTSDKFeatureColorAmbientLight?
    
    private var featureWasEnabled = false
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }

    public override func viewDidLoad() {
        super.viewDidLoad();
        
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
        mColorAmbientLightFeature = self.node.getFeatureOfType(BlueSTSDKFeatureColorAmbientLight.self) as? BlueSTSDKFeatureColorAmbientLight
        if let feature = mColorAmbientLightFeature{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    public func stopNotification(){
        if let feature = mColorAmbientLightFeature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }


    @objc func didEnterForeground() {
        mColorAmbientLightFeature = self.node.getFeatureOfType(BlueSTSDKFeatureColorAmbientLight.self) as? BlueSTSDKFeatureColorAmbientLight
        if !(mColorAmbientLightFeature==nil) && node.isEnableNotification(mColorAmbientLightFeature!) {
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

extension ColorAmbientLightViewController : BlueSTSDKFeatureDelegate{
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        mColorAmbientLightFeature = self.node.getFeatureOfType(BlueSTSDKFeatureColorAmbientLight.self) as? BlueSTSDKFeatureColorAmbientLight
        
        if mColorAmbientLightFeature != nil{
            
            let luxValue = mColorAmbientLightFeature!.getLuxValue(sample: sample)
            let luxLabel = String("\(luxValue) Lux")
            let luxProgress = Float(Float(luxValue)/Float(DATA_MAX_LUX))
            //let luxProgress = Float(((luxValue - DATA_MIN_LUX) * 100) / (DATA_MAX_LUX - DATA_MIN_LUX))
            print("Lux Progress \(luxProgress)")
            
            let cctValue = mColorAmbientLightFeature!.getCCTValue(sample: sample)
            let cctLabel = String("\(cctValue) CCT")
            let cctProgress = Float(Float(cctValue)/Float(DATA_MAX_CCT))
            //let cctProgress = Float(((cctValue - DATA_MIN_CCT) * 100) / (DATA_MAX_CCT - DATA_MIN_CCT))
            print("CCT Progress \(cctProgress)")
            
            let uvValue = mColorAmbientLightFeature!.getUVIndexValue(sample: sample)
            let uvLabel = String("\(uvValue) UV Index")
            let uvProgress = Float(Float(uvValue)/Float(DATA_MAX_UV_INDEX))
            //let uvProgress = Float(((uvValue - DATA_MIN_UV_INDEX) * 100) / (DATA_MAX_UV_INDEX - DATA_MIN_UV_INDEX))
            print("UV Progress \(uvProgress)")
            
            DispatchQueue.main.async {
                self.textViewLux.text = luxLabel
                self.progressBarLux.progress = luxProgress
                
                self.textViewCCT.text = cctLabel
                self.progressBarCCT.progress = cctProgress
                
                self.textViewUVIndex.text = uvLabel
                self.progressBarUVIndex.progress = uvProgress
            }
            
        }
        
    }
    
}
