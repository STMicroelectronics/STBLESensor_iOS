//
//  LevelDemoMode.swift
//  STDemos
//
//  Created by Luca Pezzoni on 15/10/2026.
//

enum LevelDemoMode: CaseIterable {
    case pitchRoll
    case pitchOnly
    case rollOnly
    
    var title: String {
        switch self {
        case .pitchRoll: return "Pitch/Roll"
        case .pitchOnly: return "Pitch"
        case .rollOnly: return "Roll"
        }
    }
}
