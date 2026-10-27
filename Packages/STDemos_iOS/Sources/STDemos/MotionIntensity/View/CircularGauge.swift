//
//  CircularGauge.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import SwiftUI
import STUI


struct CircularGauge: View {
    var value: Double          // Current value (e.g., 0 to 100)
    var minValue: Double = 0   // Minimum bound
    var maxValue: Double = 100 // Maximum bound
    var lineWidth: CGFloat = 20
    var gradientColors: [Color] = [SUIColorLayout.errorRed.color, SUIColorLayout.yellow.color, SUIColorLayout.successGreen.color]
    var label: String = "PERCENT"
    
    // Gauge sweep angles (e.g., standard speedometer style: 135° to 405°)
    private let startAngle: Angle = .degrees(135)
    private let totalAngleSpan: Double = 270
    private let endAngle: Angle = .degrees(405)
    
    private var progress: Double {
        let clampedValue = min(max(value, minValue), maxValue)
        return (clampedValue - minValue) / (maxValue - minValue)
    }
    
    private var currentEndAngle: Angle {
        .degrees(startAngle.degrees + (totalAngleSpan * progress))
    }
    
    var body: some View {
        ZStack {
            // 1. Background Track
            ArcShape(startAngle: startAngle, endAngle: .degrees(startAngle.degrees + totalAngleSpan))
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // 2. Foreground Progress Arc with Gradient
            ArcShape(startAngle: startAngle, endAngle: currentEndAngle)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: startAngle,
                        endAngle: endAngle
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .animation(.easeInOut(duration: 0.6), value: value)
            
            // 3. Center Text Display
            VStack(spacing: 4) {
                Text("\(Int(value))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText(value: value))
                    .animation(.easeInOut(duration: 0.6), value: value)
                
                Text(label)
                //                    .font(.caption2)
                //                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .padding(lineWidth / 2)
    }
}
