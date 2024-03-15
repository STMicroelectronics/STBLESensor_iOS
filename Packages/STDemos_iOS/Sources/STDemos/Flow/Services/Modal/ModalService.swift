//
//  ModalService.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

enum ModalService {
    
    static func showAlert(with title: String?,
                          message: String?,
                          okTitle: String?,
                          cancelTitle: String?,
                          completion: ((Bool) -> Void)?) {
        
        let delegate = UIApplication.shared.delegate
        
        guard let controller = delegate?.window??.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if okTitle != nil {
            let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
                if let block = completion {
                    block(true)
                }
            }
            
            alert.addAction(okAction)
        }
        
        if cancelTitle != nil {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                if let block = completion {
                    block(false)
                }
            }
            
            alert.addAction(cancelAction)
        }
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true)
        }
    }
    
    static func showMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "SensorTile.box",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showWarningMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Warning",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showConfirm(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Warning",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: "Cancel",
                  completion: completion)
    }
    
    static func showUploadMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "Upload",
                  message: text,
                  okTitle: "Ok",
                  cancelTitle: nil,
                  completion: completion)
    }
    
}

