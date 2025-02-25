//
//  URL+Helper.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import Foundation

extension URL {
    var createdDate: Date {
        let _ = self.startAccessingSecurityScopedResource()
        let attributes = try! FileManager.default.attributesOfItem(atPath: self.path)
        let creationDate = attributes[.creationDate] as? Date ?? Date()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        return creationDate
    }
    var modifiedDate: Date {
        let _ = self.startAccessingSecurityScopedResource()
        let attributes = try! FileManager.default.attributesOfItem(atPath: self.path)
        let modificationDate = attributes[.modificationDate] as? Date ?? Date()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        return modificationDate
    }
    var size: Int64 {
        let _ = self.startAccessingSecurityScopedResource()
        let attributes = try! FileManager.default.attributesOfItem(atPath: self.path)
        let size = attributes[.size] as? Int64 ?? 0
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        return size
    }
}
