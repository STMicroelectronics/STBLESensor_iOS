//
//  FileManagerBinaryContent.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

extension FileManager {
    
    func customBinaryContentFolder() -> URL {
        let pathDocumentFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return pathDocumentFolder.appendingPathComponent("BinaryContent")
    }
    
    func createBinaryContentFolderIfNeeded() {
#if DEBUG
        print(customBinaryContentFolder().path)
#endif
        
        if !FileManager.default.fileExists(atPath: customBinaryContentFolder().path) {
            do {
                try FileManager.default.createDirectory(at: customBinaryContentFolder(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
    }
}
