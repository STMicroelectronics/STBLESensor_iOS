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
    certificateValue.data(using: .utf8)!.withUnsafeBytes({ (bytes: UnsafePointer<Int8>) -> Void in
        BIO_puts(buffer, bytes)
    })
    let certificate = PEM_read_bio_X509(buffer, nil, nil, nil)
    //X509_print_fp(stdout, certificate)
    // Read private key
    let privateKeyBuffer = BIO_new(BIO_s_mem())
    privateKeyValue.data(using: .utf8)!.withUnsafeBytes({ (bytes: UnsafePointer<Int8>) -> Void in
        BIO_puts(privateKeyBuffer, bytes)
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
