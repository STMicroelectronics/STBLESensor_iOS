//
//  FileManager+Helper.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 17/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
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
