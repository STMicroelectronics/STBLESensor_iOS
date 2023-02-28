//
//  DocumentSelector.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 27/01/21.
//

import UIKit

public class DocumentSelector: NSObject, UIDocumentPickerDelegate {
    private var completion: (URL) -> Void = { _ in }
    
    public func selectFile(from viewController: UIViewController, _ completion: @escaping (URL) -> Void) {
        self.completion = completion
        
        let controller = UIDocumentPickerViewController(documentTypes: ["public.data"], in: UIDocumentPickerMode.import)
        controller.delegate = self
        controller.allowsMultipleSelection = false
        controller.modalPresentationStyle = .fullScreen
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
