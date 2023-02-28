//
//  ToFMultiObjectViewController.swift
//  W2STApp

import Foundation
import BlueSTSDK

class ToFMultiObjectViewController : BlueMSDemoTabViewController {
    
    private let mPersonIcons: [UIImage?] = [
        /** 0  -> Low Battery */
        UIImage(named: "tof_not_presence", in: Bundle(for: ToFMultiObjectViewController.self), compatibleWith: nil) ?? .none,
        /** 1  -> Battery ok */
        UIImage(named: "tof_presence", in: Bundle(for: ToFMultiObjectViewController.self), compatibleWith: nil) ?? .none
    ]
    
    /** Presence Section */
    @IBOutlet weak var mObjSwitch: UISwitch!
    @IBOutlet weak var mPresenceCard: UIStackView!
    
    @IBAction func setOnCheckedChangeListener(_ sender: UISwitch) {
        if(mObjSwitch.isOn){
            mPresenceDemo = true
            if !(mToFMultiObjectFeature == nil){
                mToFMultiObjectFeature?.enablePresenceRecognition(f: mToFMultiObjectFeature!)
            }
        }else{
            mPresenceDemo = false
            if !(mToFMultiObjectFeature == nil){
                mToFMultiObjectFeature?.disablePresenceRecognition(f: mToFMultiObjectFeature!)
            }
        }
    }
    
    /** Person detection section */
    @IBOutlet weak var mPersonCard: UIStackView!
    @IBOutlet weak var mPersonImage: UIImageView!
    @IBOutlet weak var mPersonLabel: UILabel!
    
    /** Objects detection section */
    @IBOutlet weak var mCard_0: UIStackView!
    @IBOutlet weak var mObjText_0: UILabel!
    
    /** Object 1 */
    @IBOutlet weak var mCard_1: UIStackView!
    @IBOutlet weak var mObjText_1: UILabel!
    @IBOutlet weak var mObjProg_1: UIProgressView!
    
    /** Object 2 */
    @IBOutlet weak var mCard_2: UIStackView!
    @IBOutlet weak var mObjText_2: UILabel!
    @IBOutlet weak var mObjProg_2: UIProgressView!
    
    /** Object 3 */
    @IBOutlet weak var mCard_3: UIStackView!
    @IBOutlet weak var mObjText_3: UILabel!
    @IBOutlet weak var mObjProg_3: UIProgressView!
    
    /** Object 4 */
    @IBOutlet weak var mCard_4: UIStackView!
    @IBOutlet weak var mObjText_4: UILabel!
    @IBOutlet weak var mObjProg_4: UIProgressView!
    
    
    private var mToFMultiObjectFeature:BlueSTSDKFeatureToFMultiObject?
    
    private var featureWasEnabled = false
    
    private var mPresenceDemo = false
    
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
        mToFMultiObjectFeature = self.node.getFeatureOfType(BlueSTSDKFeatureToFMultiObject.self) as? BlueSTSDKFeatureToFMultiObject
        if let feature = mToFMultiObjectFeature{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    public func stopNotification(){
        if let feature = mToFMultiObjectFeature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    /**Object 1*/
    @objc func didEnterForeground() {
        mToFMultiObjectFeature = self.node.getFeatureOfType(BlueSTSDKFeatureToFMultiObject.self) as? BlueSTSDKFeatureToFMultiObject
        if !(mToFMultiObjectFeature==nil) && node.isEnableNotification(mToFMultiObjectFeature!) {
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

extension ToFMultiObjectViewController : BlueSTSDKFeatureDelegate{
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        mToFMultiObjectFeature = self.node.getFeatureOfType(BlueSTSDKFeatureToFMultiObject.self) as? BlueSTSDKFeatureToFMultiObject
        
        if let feature = mToFMultiObjectFeature{
            if (mPresenceDemo==false) {
                DispatchQueue.main.async {
                    self.mPersonCard.isHidden = true
                    self.mCard_0.isHidden = false
                    self.mCard_1.isHidden = true
                    self.mCard_2.isHidden = true
                    self.mCard_3.isHidden = true
                    self.mCard_4.isHidden = true
                    //let mNumObj0 = feature.getNumObjects(sample: sample)
                    let valueStr0 = feature.getNumObjectsToString(sample: sample)
                    
                    self.mObjText_0.text = valueStr0
                    
                    let distance1 = feature.getDistance(sample: sample, obj_num: 0)
                    let distance2 = feature.getDistance(sample: sample, obj_num: 1)
                    let distance3 = feature.getDistance(sample: sample, obj_num: 2)
                    let distance4 = feature.getDistance(sample: sample, obj_num: 3)
                    
                    if !(distance1==0){
                        let valueStr1 = feature.getDistanceToString(sample: sample, obj_num: 0)
                        self.mObjText_1.text = valueStr1
                        let progress1 = Float(Float(distance1)/4000)
                        self.mObjProg_1.progress = progress1
                        self.mCard_1.isHidden = false
                    }
                    if !(distance2==0){
                        let valueStr2 = feature.getDistanceToString(sample: sample, obj_num: 1)
                        self.mObjText_2.text = valueStr2
                        let progress2 = Float(Float(distance2)/4000)
                        self.mObjProg_2.progress = progress2
                        self.mCard_2.isHidden = false
                    }
                    if !(distance3==0){
                        let valueStr3 = feature.getDistanceToString(sample: sample, obj_num: 2)
                        self.mObjText_3.text = valueStr3
                        let progress3 = Float(Float(distance3)/4000)
                        self.mObjProg_3.progress = progress3
                        self.mCard_3.isHidden = false
                    }
                    if !(distance4==0){
                        let valueStr4 = feature.getDistanceToString(sample: sample, obj_num: 3)
                        self.mObjText_4.text = valueStr4
                        let progress4 = Float(Float(distance4)/4000)
                        self.mObjProg_4.progress = progress4
                        self.mCard_4.isHidden = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.mPersonCard.isHidden = false
                    self.mCard_0.isHidden = true
                    self.mCard_1.isHidden = true
                    self.mCard_2.isHidden = true
                    self.mCard_3.isHidden = true
                    self.mCard_4.isHidden = true
                    let numPresence = feature.getNumPresence(sample: sample)
                    let valueStr = feature.getNumPresenceToString(sample: sample)
                   
                    if !(numPresence==0){
                        self.mPersonImage.image = self.mPersonIcons[1]
                    } else {
                        self.mPersonImage.image = self.mPersonIcons[0]
                    }
                    
                    self.mPersonLabel.text = valueStr
                }
            }
        }
        
    }
    
}
