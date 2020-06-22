//
//  STAzureDashboardClient.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 12/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//
import SwiftyJSON
import Foundation
import AzureIoTHubClient

class STAzureDashboardClient: BlueMSCloudIotClient {

    private let mConnectionString:String
    
   private let networkQueue = DispatchQueue(label: "ST Azure Dashboard I/O")
   private var doWork:DispatchWorkItem!
   
    private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE?;
    private var mConnectionCallback:OnIotClientActionCallback?
    private var mFwUpgradeCallback:OnFwUpgradeAvailableCallback?
    var isConnected: Bool = false
    
    init(connectionString:String) {
        mConnectionString = connectionString
    }
    
    private func getSelfCPtr()->UnsafeMutableRawPointer{
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func connect(_ onComplete: OnIotClientActionCallback?) {
        doWork = DispatchWorkItem{ [weak self] in
            guard let client = self else{
                return
            }
            guard let device = client.iotHubClientHandle else {
                client.networkQueue.asyncAfter(deadline: .now() + 1.0, execute: client.doWork)
                return
            }
            IoTHubClient_LL_DoWork(device)
            client.networkQueue.asyncAfter(deadline: .now() + 0.5, execute: client.doWork)
        }
        networkQueue.async(execute: doWork)
        mConnectionCallback = onComplete
        self.iotHubClientHandle = IoTHubClient_LL_CreateFromConnectionString(mConnectionString, MQTT_Protocol)
        let ptr = getSelfCPtr()
        IoTHubClient_LL_SetDeviceTwinCallback(self.iotHubClientHandle, myTwinCallback, ptr)
    }
    
    func sendTelemetryData(messageStr:String){
           guard isConnected else {
               return
           }
           let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(messageStr, messageStr.utf8.count)
           
           if (messageHandle != OpaquePointer.init(bitPattern: 0)) {
               
               if (IOTHUB_CLIENT_OK == IoTHubClient_LL_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, nil)) {
                   print("message Sent async")
               }
           }
       }
    
    func enableCloudFwUpgrade(callback: @escaping OnFwUpgradeAvailableCallback)->Bool{
        let fwUpgradeMethod = """
        {"SupportedMethods":{"\(Self.METHOD_NAME)--\(Self.METHOD_PARAM)-string": "Updates device Firmware."}}
        """
        mFwUpgradeCallback = callback
        reportPropertyData(fwUpgradeMethod)
        return IoTHubClient_LL_SetDeviceMethodCallback(iotHubClientHandle,myCloudMethodCallback,getSelfCPtr()) == IOTHUB_CLIENT_OK
    }
    
    private func reportPropertyData(_ str:String){
        let messageData = str.data(using: .utf8)
        messageData?.withUnsafeBytes{ ptr in
            let typePtr = ptr.bindMemory(to: UInt8.self)
            IoTHubClient_LL_SendReportedState(iotHubClientHandle, typePtr.baseAddress, typePtr.count, mReportPropertyCallback, nil)
        }
    }
    
    func reportTelemetryInterval( seconds:TimeInterval){
        let message = """
        { "TelemetryInterval" : \(Int(seconds)) }
        """
        reportPropertyData(message)
    }
    
    private let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, _ in
        if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
            print("message Sent")
        } else {
            print ("message fail")
        }
    }
    

    private let myCloudMethodCallback : IOTHUB_CLIENT_DEVICE_METHOD_CALLBACK_ASYNC = { methodName, methodData,methodDataSize,resposeDataPtr,responseSizePtr,context in
        guard let ctx = context else{
            let message = "\"Invalid user contex\""
            let messageLength = message.utf8.count
              strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                  resposeDataPtr?.pointee=uint8Ptr
                  responseSizePtr?.pointee = messageLength
              }
            return 500
        }
        var client = Unmanaged<STAzureDashboardClient>.fromOpaque(ctx).takeUnretainedValue()
        guard let name = methodName,
            let data = methodData else{
            let message = "\"Empty method name or method data\""
            let messageLength = message.utf8.count
              strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                  resposeDataPtr?.pointee=uint8Ptr
                  responseSizePtr?.pointee = messageLength
              }
            return 500
        }
        let nameStr = String(cString: name)
        guard nameStr == STAzureDashboardClient.METHOD_NAME else{
            let message = "\"Unknown Method\""
            let messageLength = message.utf8.count
            strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                resposeDataPtr?.pointee=uint8Ptr
                responseSizePtr?.pointee = messageLength
            }
            return 404
        }
        let dataPtr = UnsafeBufferPointer(start: data, count: methodDataSize)
        guard let jsonParam = try? JSON(data: Data(buffer: dataPtr)) else{
            let message = "\"Invalid Parameter\""
            let messageLength = message.utf8.count
              strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                  resposeDataPtr?.pointee=uint8Ptr
                  responseSizePtr?.pointee = messageLength
              }
            return 500
        }
        print(name)
        if let location = jsonParam[STAzureDashboardClient.METHOD_PARAM].string,
           let url = URL(string:location){
            client.mFwUpgradeCallback?(url);
            let message = "{}"
            let messageLength = message.utf8.count
              strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                  resposeDataPtr?.pointee=uint8Ptr
                  responseSizePtr?.pointee = messageLength
              }
            return 200
        }else {
            let message = "\"Missing Parameter\""
            let messageLength = message.utf8.count
              strdup(message).withMemoryRebound(to: UInt8.self, capacity: messageLength){ uint8Ptr in
                  resposeDataPtr?.pointee=uint8Ptr
                  responseSizePtr?.pointee = messageLength
              }
            return 500
        }
        
    }
    
    private let myTwinCallback: IOTHUB_CLIENT_DEVICE_TWIN_CALLBACK = { status, data, dataSize, context in
        guard let ctx = context else{
            return
        }
        var client = Unmanaged<STAzureDashboardClient>.fromOpaque(ctx).takeUnretainedValue()
        if(status == DEVICE_TWIN_UPDATE_COMPLETE){
            print("TwinCallback: Complete")
            client.isConnected = true
            client.mConnectionCallback?(nil)
        }
        if(status == DEVICE_TWIN_UPDATE_PARTIAL){
            client.isConnected = false
            client.mConnectionCallback?(nil)
            print("TwinCallback: Partial")
        }
        print("TwinCallback")
    }
    
    private let mReportPropertyCallback: IOTHUB_CLIENT_REPORTED_STATE_CALLBACK = { status , _ in
        print("Reported Status: \(status)")
    }
        
    func disconnect(_ onComplete: OnIotClientActionCallback?) {
        isConnected = false
        IoTHubClient_LL_Destroy(iotHubClientHandle)
        iotHubClientHandle = nil
        mConnectionCallback = nil
        mFwUpgradeCallback = nil
        onComplete?(nil)
    }
    
    private static let METHOD_NAME = "FirmwareUpdate"
    private static let METHOD_PARAM = "FwPackageUri"
}
