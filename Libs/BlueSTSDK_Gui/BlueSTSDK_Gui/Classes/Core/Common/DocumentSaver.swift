//
//  DocumentSaver.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 28/01/21.
//

import UIKit

public class DocumentSaver: NSObject, UIDocumentPickerDelegate {
    private var completion: (URL) -> Void = { _ in }
    
    public func saveFile(atURL url: URL, from viewController: UIViewController, _ completion: @escaping (URL) -> Void) {
        self.completion = completion
        
        let controller = UIDocumentPickerViewController(url: url, in: .exportToService)
        controller.delegate = self
        viewController.present(controller, animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            completion(url)
        }
    }
}
