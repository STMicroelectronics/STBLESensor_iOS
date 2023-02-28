//
//  ModalService.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 17/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
                  okTitle: "ok".localized(),
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showWarningMessage(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "warning".localized(),
                  message: text,
                  okTitle: "ok".localized(),
                  cancelTitle: nil,
                  completion: completion)
    }
    
    static func showConfirm(with text: String?, completion: ((Bool) -> Void)? = nil) {
        showAlert(with: "warning".localized(),
                  message: text,
                  okTitle: "ok".localized(),
                  cancelTitle: "cancel".localized(),
                  completion: completion)
    }
}
