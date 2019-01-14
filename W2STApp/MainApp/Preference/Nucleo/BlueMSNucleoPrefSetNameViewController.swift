//
//  BlueMSNucleoPrefSetNameViewController.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 02/11/2017.
//  Copyright © 2017 STMicroelectronics. All rights reserved.
//

import Foundation
import BlueSTSDK
public class BlueMSNucleoPrefSetNameViewController : UIViewController{
    
    private static let NAME_CHANGED_TITLE:String = {
        let bundle = Bundle(for: BlueMSNucleoPrefSetNameViewController.self)
        return NSLocalizedString("Change Name", tableName: nil, bundle: bundle,
                                 value: "Change Name", comment: "")
    }();
    
    private static let NAME_CHANGED_SUCCESS:String = {
        let bundle = Bundle(for: BlueMSNucleoPrefSetNameViewController.self)
        return NSLocalizedString("Node name changed", tableName: nil, bundle: bundle,
                                 value: "Node name changed", comment: "")
    }();
    
    private static let NAME_CHANGED_FAIL:String = {
        let bundle = Bundle(for: BlueMSNucleoPrefSetNameViewController.self)
        return NSLocalizedString("Invalid node name", tableName: nil, bundle: bundle,
                                 value: "Invalid node name", comment: "")
    }();
    
    public var node:BlueSTSDKNode!;
    
    @IBOutlet weak var mNameField: UITextField!
    
    public override func viewDidLoad() {
        mNameField.text = node.name;
    }
    
    private func isNewNameCorrect(_ name:String?) -> Bool{
        if(name==nil){
            return false;
        }
        if(name!.isEmpty){
            return false;
        }
        if(name!.count>7){
            return false;
        }
        return true;
    }
    
    @IBAction func onSaveClick(_ sender: UIButton) {
        let newName = mNameField.text;
        guard isNewNameCorrect(newName) else{
            showAllert(title: BlueMSNucleoPrefSetNameViewController.NAME_CHANGED_TITLE,
                       message: BlueMSNucleoPrefSetNameViewController.NAME_CHANGED_FAIL,
                       closeController: true)
            return;
        }
        if let console = node.debugConsole, let name = newName{
            NucleoConsole(console).setName(newName: name);
            showAllert(title: BlueMSNucleoPrefSetNameViewController.NAME_CHANGED_TITLE,
                       message: BlueMSNucleoPrefSetNameViewController.NAME_CHANGED_SUCCESS,
                       closeController: true)
        }
        
    }
    
}
