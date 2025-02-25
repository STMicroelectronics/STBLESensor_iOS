//
//  AnalyticsServiceAIoTCraftProtocol.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol AnalyticsServiceAIoTCraftProtocol: AnalyticsService {
    func startDemo(withName name: String)

    func stopDemo(withName name: String)
    
    func etnaBasicAnalytics()
    
    func etnaUserProfileAnalytics()
    
    func etnaNodeBaseAnalytics(nodeName: String, nodeType: String)
    
    func etnaNodeFwVersionAnalytics(fwVersion: String)
    
    func etnaNodeFullFwNameAnalytics(fullFwName: String)
    
    func trackQRCodeScanFlow(withProjectName projectName: String, andProjectType projectType: Int)
    
    func trackProjectsFlows(withProjectType projectType: Int, withUseCase useCase: Int, andProjectName projectName: String, andFirmwareName firmwareName: String, andBoardType boardType: String)
    
    func trackDatasetFlows(withUseCase useCae: Int, andDatasetName datasetName: String, andFirmwareName firmwareName: String?, andBoardType boardType: String?)
    
    func trackCatalogFlow(withBoardName boardName: String)
    
    func trackDocumentationFlow()
}
