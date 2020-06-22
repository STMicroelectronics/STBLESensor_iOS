/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */
import Foundation

func PKSCS12_storeKeyOnTempFile( certificate:UnsafeMutablePointer<PKCS12>?)->URL?{
    guard certificate != nil else {
        return nil;
    }
    let fileManager = FileManager.default
    let tempDirectory = NSTemporaryDirectory() as NSString
    let path = tempDirectory.appendingPathComponent("ssl.p12")
    fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    guard let fileHandle = FileHandle(forWritingAtPath: path) else {
        NSLog("Cannot open file handle: \(path)")
        return nil;
    }
    let p12File = fdopen(fileHandle.fileDescriptor, "w")
    i2d_PKCS12_fp(p12File, certificate)
    fclose(p12File)
    fileHandle.closeFile()
    return URL(fileURLWithPath: path);
}

func PKSCS12_createCertificate(certificateName:String, certificateValue:String, password:String, privateKeyValue:String)->UnsafeMutablePointer<PKCS12>?{
    // Read certificate
    let buffer = BIO_new(BIO_s_mem())
    certificateValue.data(using: .utf8)!.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
        let int8Ptr = ptr.bindMemory(to: Int8.self)
        BIO_puts(buffer, int8Ptr.baseAddress!)
    })
    /*
    certificateValue.data(using: .utf8)!.withUnsafeBytes({ (bytes: UnsafePointer<Int8>) -> Void in
        BIO_puts(buffer, bytes)
    })*/
    let certificate = PEM_read_bio_X509(buffer, nil, nil, nil)
    //X509_print_fp(stdout, certificate)
    // Read private key
    let privateKeyBuffer = BIO_new(BIO_s_mem())
    privateKeyValue.data(using: .utf8)!.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
        let int8Ptr = ptr.bindMemory(to: Int8.self)
        BIO_puts(privateKeyBuffer, int8Ptr.baseAddress!)
    })
    let privateKey = PEM_read_bio_PrivateKey(privateKeyBuffer, nil, nil, nil)
    //PEM_write_PrivateKey(stdout, privateKey, nil, nil, 0, nil, nil)
    // Check if private key matches certificate
    guard X509_check_private_key(certificate, privateKey) == 1 else {
        NSLog("Private key does not match certificate")
        return nil
    }
    // Set OpenSSL parameters
    OPENSSL_add_all_algorithms_noconf()
    ERR_load_crypto_strings()
    
    let passPhrase = UnsafeMutablePointer(mutating: (password as NSString).utf8String)
    let name = UnsafeMutablePointer(mutating: (certificateName as NSString).utf8String)
    guard let p12 = PKCS12_create(passPhrase, name, privateKey, certificate, nil, 0, 0, 0, 0, 0) else {
        NSLog("Cannot create P12 keystore:")
        ERR_print_errors_fp(stderr)
        return nil
    }
    return p12;
}
