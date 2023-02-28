//
//  UIViewController+showDialog.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 02/09/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    private static let OK_BUTTON =  {
        return  NSLocalizedString("Ok",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Ok",
                                  comment: "Ok");
    }()
    
    func showMessage(title:String?, msg:String?, closeVc:Bool = false){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if(closeVc){
            let okButton = UIAlertAction(title: UIViewController.OK_BUTTON, style: .default){ _ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okButton)
        }else{
            alert.addAction(UIAlertAction(title: UIViewController.OK_BUTTON, style: .default))
        }
        
        self.present(alert, animated: true)
    }
    
}
