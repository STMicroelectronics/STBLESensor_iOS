/*
 * BlueMSDemosViewController+PnPL.swift
 *
 * Copyright (c) 2022 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file in
 * the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 */

import Foundation
import Toast_Swift

extension BlueMSDemosViewController {
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let dtmi = PnPLikeService().currentPnPLDtmi()
        
        if(dtmi != nil){
            navigationController?.viewControllers.forEach{ vc in
                if(vc is BlueSTSDKDemoViewController){
                    vc.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: UIImage(named: "ic_settings"), style: .plain, target: self, action: #selector(pnpLSettingsTapped)))
                }
            }
        }
    }
    
    @objc
    func pnpLSettingsTapped() {
        let dtmi = PnPLikeService().currentPnPLDtmi()
        
        let originalDemoName = selectedViewController?.tabBarItem.title
        
        var demo = originalDemoName
        demo = demo?.lowercased()
        demo = demo?.replacingOccurrences(of: " ", with: "_")
        
        print(selectedViewController?.tabBarItem.title ?? "")
        
        guard let demo = demo else { return }
        guard let dtmi = dtmi else { return }
        
        let detectedDemosComponent = findDemosComponent(dtmi)
        var detectedDemo: Bool = false
        
        if(detectedDemosComponent) {
            dtmi.forEach { pnpElement in
                pnpElement.contents.forEach { content in
                    if(content.name == demo){
                        if #available(iOS 13.0, *) {
                            detectedDemo = true
                            PnPLikeService().storePnPLCurrentDemo(demo)
                            
                            let storyboard = UIStoryboard(name: "PnPLikeDemo", bundle: Bundle(for: Self.self))
                            let secondVC = storyboard.instantiateViewController(identifier: "PnPLikeViewControllerID")
                            
                            BlueSTSDKDemoViewProtocolUtil.setupDemoProtocol(demo: secondVC, node: node, menuDelegate: nil)
                            
                            let navController = UINavigationController(rootViewController: secondVC)
                            secondVC.title = originalDemoName
                            present(navController, animated: true)
                        }
                    }
                }
            }
        }
        if !(detectedDemo){
            view?.makeToast("No custom settings provided for current demo.", duration: 2)
        }
    }
    
    private func findDemosComponent(_ dtmi: PnPLikeDtmiCommands) -> Bool {
        var isDetected: Bool = false
        dtmi.forEach { pnpElement in
            if(pnpElement.contents.contains(where: { content in content.name == "applications_stblesensor" })) {
                isDetected = true
            }
        }
        return isDetected
    }
}
