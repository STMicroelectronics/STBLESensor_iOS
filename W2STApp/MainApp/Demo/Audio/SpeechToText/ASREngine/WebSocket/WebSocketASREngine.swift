

import Foundation
import Starscream

class WebSocketASRDescription : BlueVoiceASRDescription{
    
    
    public let needAuthKey = true;
    public let hasContinuousRecognizer = true;
    public let name = "Generic WebSocket";
    public let supportedLanguages = [ BlueVoiceLanguage.UNKNOWN]
    
    func build(withLanguage lang: BlueVoiceLanguage, samplingRateHz: UInt) -> BlueVoiceASREngine? {
        return BlueVoiceWebSocketASREngine();
    }
}

public class BlueVoiceWebSocketASREngine : BlueVoiceASREngine{
    
    static var engineDescription = WebSocketASRDescription() as BlueVoiceASRDescription;
    
    private var mAsrKey:BlueVoiceWebSocketASRKey?;
    
    private var mWebSocket:WebSocket!;
    private var mSpeechServiceConnected:Bool = false;
    private var mSpeechTextCallback:BlueVoiceAsrRequestCallback?;
    private var mRequestCallback:BlueVoiceAsrRequestCallback?;
    
    func getAuthKeyDialog() -> UIViewController? {
        let storyBoard = UIStoryboard(name: "SpeechToText", bundle: Bundle(for: Self.self))
        let viewController = storyBoard.instantiateViewController(withIdentifier: "WebSocketParamViewController") as! BlueVoiceWebSocketParamViewController;
        viewController.delegate=self;
        return viewController;
    }
    
    
    func startListener(onConnect: @escaping (Error?) -> Void) {
        var request = URLRequest(url: URL(string: mAsrKey!.endpoint)!)
        if let user = mAsrKey?.userName,
            let pwd = mAsrKey?.password{
            request.addAtuhorization(user: user,password: pwd)
        }

        mWebSocket = WebSocket(request: request)
        mWebSocket.onConnect = { onConnect(nil)}
        mWebSocket.onDisconnect = onConnect;
        mWebSocket.onText = { text in
            self.mRequestCallback?.onAsrRequestSuccess(withText: text)
        }
        mWebSocket.connect()
    }
    
    func stopListener() {
        mWebSocket.disconnect()
    }
    
    func destroyListener() {
        
    }
    
    func hasLoadedAuthKey() ->Bool{
        mAsrKey = loadAsrKey()
        return mAsrKey != nil;
    }
    
    /// update the sampling frequency from 8k to 16k.
    /// it duplicate the values
    ///
    /// - Parameter audio: buffer to convert
    /// - Returns: buffer with the same content but with a double sampling rate
    private func upsamplingAudioBuffer(_ audio:Data)->Data{
        // allocate the new buffer
        var upsampligAudio = Data(capacity: 2*audio.count)
        audio.withUnsafeBytes{(audioSamples: UnsafePointer<UInt16>) in
            //for each audio sample
            for i in 0..<audio.count/2{
                //get the pointer
                let value = audioSamples.advanced(by: i);
                //eavluate as uint8
                value.withMemoryRebound(to: UInt8.self, capacity: 2, { (bytes) in
                    //copy the value in the output buffer 2 times
                    upsampligAudio.append(bytes, count: 2)
                    upsampligAudio.append(bytes, count: 2)
                })
            }
        }
        return upsampligAudio;
    }
    
    func sendASRRequest(audio: Data, callback: BlueVoiceAsrRequestCallback) -> Bool {
        if(mWebSocket.isConnected){
            mWebSocket.write(data: upsamplingAudioBuffer(audio))
        }
        return true;
    }
}

extension BlueVoiceWebSocketASREngine : BlueVoiceWebSocketParamDelegate{
    public func loadAsrKey() -> BlueVoiceWebSocketASRKey? {
        return BlueVoiceWebSocketASRKey.load()
    }
    
    public func storeAsrKey(_ key: BlueVoiceWebSocketASRKey) {
        key.store()
    }
}

extension URLRequest{
    mutating func addAtuhorization(user:String,password:String){
        let authData = "\(user):\(password)"
            .data(using: .utf8)?.base64EncodedString()
        if let base64AuthData = authData {
            setValue("Basic \(base64AuthData)", forHTTPHeaderField: "Authorization")
       }
    }
}
