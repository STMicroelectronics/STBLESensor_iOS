//
//  FileManager+Helper.swift
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
    
    func documentFolder() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func customFlowsFolder() -> URL {
        return documentFolder().appendingPathComponent(customFlowsDirectory)
    }
    
    func createFlowsFolderIfNeeded() {
        #if DEBUG
        print(customFlowsFolder().path)
        #endif
        
        if !FileManager.default.fileExists(atPath: customFlowsFolder().path) {
            do {
                try FileManager.default.createDirectory(at: customFlowsFolder(), withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error)
            }
        }
    }
    
    func flowExists(with name: String) -> Bool {
        let sanitazedName = name.sanitazed()
        let fileName = FileManager.default.customFlowsFolder().appendingPathComponent(sanitazedName + ".json").path
        return FileManager.default.fileExists(atPath: fileName)
    }

}
