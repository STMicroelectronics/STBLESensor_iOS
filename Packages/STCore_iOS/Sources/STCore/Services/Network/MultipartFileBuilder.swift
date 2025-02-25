//
//  NetworkService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class MultipartFileBuilder {

    public let boundary: String

    private let chunkSize: Int = 4096
    private let separator: String = "\r\n"
    private var data: Data

    private let temporaryFileURL: URL
    private let temporaryFileHandle: FileHandle

    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public init(boundary: String = UUID().uuidString) throws {

        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                            isDirectory: true)

        let temporaryFilename = ProcessInfo().globallyUniqueString

        self.temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)

        FileManager.default.createFile(atPath: temporaryFileURL.path, contents: Data())

        self.temporaryFileHandle = try FileHandle(forWritingTo: temporaryFileURL)

        self.boundary = boundary
        self.data = .init()
    }

    private func boundarySeparator() -> String {
        "--\(boundary)\(separator)"
    }

    private func boundaryTerminator() -> String {
        "--\(boundary)--\(separator)"
    }

    private func appendBoundarySeparator() {
        writeStringToFileHandle(string: boundarySeparator())
    }

    private func appendBoundaryTerminator() {
        writeStringToFileHandle(string: boundaryTerminator())
    }

    private func appendSeparator() {
        writeStringToFileHandle(string: separator)
    }

    private func writeStringToFileHandle(string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            return
        }

        temporaryFileHandle.write(data)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public func add(key: String, value: String) {
        appendBoundarySeparator()
        writeStringToFileHandle(string: disposition(key) + separator)
        appendSeparator()
        writeStringToFileHandle(string: value + separator)
    }

    public func add(key: String, fileName: String, fileMimeType: String, fileData: Data) {
        appendBoundarySeparator()

//        data = try? Data(contentsOf: acquisitionInfoFile)
//        if data?.last == 0x00 {
//            data?.removeLast()
//        }
//
//        try? data?.write(to: acquisitionInfoFile)

        writeStringToFileHandle(string: disposition(key) + "; filename=\"\(fileName)\"" + separator)
        writeStringToFileHandle(string: "Content-Type: \(fileMimeType)" + separator + separator)
        temporaryFileHandle.write(fileData)

        appendSeparator()
    }

    public func add(key: String, fileName: String, fileMimeType: String, fileUrl: URL) throws {
        appendBoundarySeparator()
        writeStringToFileHandle(string: disposition(key) + "; filename=\"\(fileName)\"" + separator)
        writeStringToFileHandle(string: "Content-Type: \(fileMimeType)" + separator)
        writeStringToFileHandle(string: "Content-Length: \(fileUrl.size)" + separator + separator)

        let fileHandle = try FileHandle(forReadingFrom: fileUrl)

        autoreleasepool {
            while let data = nextData(with: fileHandle) {
                temporaryFileHandle.write(data)
            }
        }

        try fileHandle.close()

        appendSeparator()
    }

    public func getTemporaryFileURL() -> URL {
        appendBoundaryTerminator()
        try? temporaryFileHandle.close()
        return temporaryFileURL
    }

    func nextData(with fileHandle: FileHandle) -> Data? {

        let data = fileHandle.readData(ofLength: chunkSize)
        guard !data.isEmpty else { return nil }

        return data
     }

    deinit {
        try? temporaryFileHandle.close()
    }
}
