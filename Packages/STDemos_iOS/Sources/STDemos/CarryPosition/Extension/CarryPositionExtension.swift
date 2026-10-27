//
//  CarryPositionExtension.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import STBlueSDK
import STUI

extension CarryPositionType {
    func getDescription() -> String {
        switch self {
        case .inHand:
            return "Carried in hand"
        case .nearHead:
            return "Near the head"
        case .shirtPocket:
            return "In the shirt pocket"
        case .trousersPocket:
            return "In the trousers pocket"
        case .onDesk:
            return "Placed on the desk"
        case .armSwing:
            return "Swinging on the arm"
        default:
            return ""
        }
    }
    
    func getImageName() -> String? {
        switch self {
        case .inHand:
            return "carry_hand"
        case .nearHead:
            return "carry_head"
        case .shirtPocket:
            return "carry_shirt"
        case .trousersPocket:
            return "carry_trousers"
        case .onDesk:
            return "carry_desk"
        case .armSwing:
            return "carry_arm"
        default:
            return nil
        }
    }
}
