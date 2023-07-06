//
//  FilePicker.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import UniformTypeIdentifiers
import CoreServices

public enum FileType: String {
    case json = "public.json"
    case bin = "public.data"
}

public typealias FileCallback = (URL?) -> Void

public class FilePicker: NSObject {
    public static let shared = FilePicker()
    
    var completion: (FileCallback)?
    
    public override init() {
        
    }

}

extension UIViewController {
    func topPresentedViewController() -> UIViewController? {
        if let controller = presentedViewController {
            return controller.topPresentedViewController()
        }
        
        return self
    }
}

public extension FilePicker {
    func pickFile(with types: [FileType], completion: FileCallback?) {
        
        self.completion = completion
        
        let controller = UIDocumentPickerViewController(documentTypes: types.map { $0.rawValue }, in: .import)
        controller.allowsMultipleSelection = false
        controller.delegate = self
        UIApplication.shared.windows.first?
            .rootViewController?
            .topPresentedViewController()?
            .present(controller, animated: true, completion: nil)
        
    }
}

extension FilePicker: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self, let completion = self.completion else { return }
            completion(urls.first)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self, let completion = self.completion else { return }
            completion(nil)
        }
    }
}
