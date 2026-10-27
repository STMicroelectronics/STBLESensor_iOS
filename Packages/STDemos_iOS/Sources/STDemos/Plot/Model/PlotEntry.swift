//
//  PlotEntry.swift
//  STDemos
//
//  Created by Luca Pezzoni on 13/10/2026.
//

public struct PlotEntry {
    public let x: UInt64
    public let y: [Float]

    public init(x: UInt64, y: [Float]) {
        self.x = x
        self.y = y
    }
}
