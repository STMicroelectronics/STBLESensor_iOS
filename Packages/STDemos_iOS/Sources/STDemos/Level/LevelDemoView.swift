//
//  LevelDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 15/10/2026.
//

import SwiftUI
import STUI
import STBlueSDK
import STCore

public struct LevelDemoView: View {
    
    @StateObject private var viewModel = LevelDemoViewModel()
    @State private var delegateHandler: LevelNodeBlueDelegateHandler?
    
    @State private var selectedLevelDemoMode: LevelDemoMode = .pitchRoll
    @State private var mZeroPitch: Float = 0.0
    @State private var mZeroRoll: Float = 0.0
    
    private var pitch: Float {
        viewModel.pitch - mZeroPitch
    }
    
     private var roll: Float {
        viewModel.roll - mZeroRoll
    }
    
    private var isCentered: Bool {
        abs(computeXFactor(mode: selectedLevelDemoMode, pitch: pitch)) < 0.05 &&
        abs(computeYFactor(mode: selectedLevelDemoMode, roll: roll)) < 0.05
    }
    
    // Helper function to draw concentric dashed/solid circles cleanly in Canvas
    private func drawCirclePath(context: GraphicsContext, center: CGPoint, radius: CGFloat, style: StrokeStyle, color: Color) {
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .color(color),
            style: style
        )
    }
    
    // Placeholder helpers for factor computation logic matching your Android codebase
    private func computeXFactor(mode: LevelDemoMode, pitch: Float) -> Float {
        
        return switch mode {
        case .pitchRoll, .pitchOnly:
            Float(sin(Double(pitch) * .pi / 180.0))
        case .rollOnly:
            0.0
        }
        //return pitch / 90.0
    }
    
    private func computeYFactor(mode: LevelDemoMode, roll: Float) -> Float {
        return switch mode {
        case .pitchRoll, .rollOnly:
            Float(sin(Double(roll) * .pi / 180.0))
        case .pitchOnly:
            0.0
        }
        //return roll / 90.0
    }
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        @State var sizeWidth: Int = 128
        VStack(spacing: 16) {
            // Mode Selector Picker (Segmented or Menu style)
            Menu {
                ForEach(LevelDemoMode.allCases, id: \.self) { mode in
                    Button {
                        selectedLevelDemoMode = mode
                    } label: {
                        switch mode {
                        case .pitchRoll:
                            Label(mode.title, systemImage: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                        case .pitchOnly:
                            Label(mode.title, systemImage: "arrow.left.arrow.right")
                        case .rollOnly:
                            Label(mode.title, systemImage: "arrow.up.arrow.down")
                        }
                    }
                }
            }
            label: {
                Label(selectedLevelDemoMode.title , systemImage: "chevron.down").font(.title)
            }.padding(8)
            
            // Canvas drawing equivalent to Compose Canvas
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let dashStyle = StrokeStyle(lineWidth: 2, dash: [10, 10])
                let dashStyleLine = StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10, 10])
                let thickStyle = StrokeStyle(lineWidth: 32)
                let circleColor: Color = isCentered ? SUIColorLayout.successGreen.color : SUIColorLayout.yellow.color
                
                sizeWidth = Int(size.width)
                
                // Draw dashed horizontal line
                var hLine = Path()
                hLine.move(to: CGPoint(x: size.width * 0.05, y: center.y))
                hLine.addLine(to: CGPoint(x: size.width * 0.95, y: center.y))
                context.stroke(hLine, with: .color(SUIColorLayout.stGray3.color), style: dashStyleLine)

                // Draw dashed vertical line
                var vLine = Path()
                vLine.move(to: CGPoint(x: center.x, y: 0))
                vLine.addLine(to: CGPoint(x: center.x, y: size.height))
                context.stroke(vLine, with: .color(SUIColorLayout.stGray3.color), style: dashStyleLine)
                
                // Big Circle
                context.stroke(
                    Path(ellipseIn: CGRect(
                        x: center.x - (size.width * 0.9 / 2),
                        y: center.y - (size.width * 0.9 / 2),
                        width: size.width * 0.9,
                        height: size.width * 0.9
                    )),
                    with: .color(circleColor),
                    style: thickStyle
                )

                
                // 60% Dashed Fixed Circle
                drawCirclePath(context: context, center: center, radius: size.width * 0.6 / 2, style: dashStyle, color: SUIColorLayout.stGray3.color)
                
                // 30% Dashed Fixed Circle
                drawCirclePath(context: context, center: center, radius: size.width * 0.3 / 2, style: dashStyle, color: SUIColorLayout.stGray3.color)
                
                // 15% Little Dashed Fixed Circle
                drawCirclePath(context: context, center: center, radius: size.width * 0.15 / 2, style: dashStyle, color: SUIColorLayout.green.color)
                
                // Little Fixed Circle (Filled center)
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - (size.width * 0.1 / 2),
                        y: center.y - (size.width * 0.1 / 2),
                        width: size.width * 0.1,
                        height: size.width * 0.1
                    )),
                    with: .color(SUIColorLayout.stGray3.color)
                )
                
                // Moving Circle
                let xFactor = computeXFactor(mode: selectedLevelDemoMode, pitch: pitch)
                let yFactor = computeYFactor(mode: selectedLevelDemoMode, roll: roll)
                let movingX = center.x + (size.width * 0.50 * Double(xFactor))
                let movingY = center.y + (size.height * 0.50 * Double(yFactor))
                let movingRadius = size.width * 0.1 / 2
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: movingX - movingRadius,
                        y: movingY - movingRadius,
                        width: movingRadius * 2,
                        height: movingRadius * 2
                    )),
                    with: .color(circleColor)
                )
            }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.all, 16)
            
            // Bottom Controls (Pitch & Roll Rows)
            HStack(spacing: 16) {
                // Pitch Column
                VStack(spacing: 8) {
                    Button("Set zero") {
                        mZeroPitch = viewModel.pitch
                        mZeroRoll = viewModel.roll
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("Pitch")
                        //.font(.caption)
                    
                    Image(systemName: "circle.lefthalf.filled") // Equivalent to ic_half_circle
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CGFloat(sizeWidth), height: CGFloat(sizeWidth))
                        .rotationEffect(.degrees(Double(pitch)-90.0))
                        .foregroundColor(SUIColorLayout.primary.color)
                    
                    Text(String(format: "Offset: %.2f°", pitch))
                        //.font(.caption)
                }
                .frame(maxWidth: .infinity)
                
                // Roll Column
                VStack(spacing: 8) {
                    Button("Reset zero") {
                        mZeroPitch = 0.0
                        mZeroRoll = 0.0
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("Roll")
                        //.font(.caption)
                    
                    Image(systemName: "circle.lefthalf.filled")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: CGFloat(sizeWidth), height: CGFloat(sizeWidth))
                        .rotationEffect(.degrees(Double(roll)-90.0))
                        .foregroundColor(SUIColorLayout.primary.color)
                    
                    Text(String(format: "Offset: %.2f°", roll))
                        //.font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
        .padding()
        .animation(.easeInOut, value: isCentered)
        .onAppear {
            delegateHandler = LevelNodeBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class LevelNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: LevelDemoViewModel
    
    init(viewModel: LevelDemoViewModel) {
        self.viewModel = viewModel
    }
    
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {}
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        guard let sample = sample else { return }
        switch sample {
        case let sample as FeatureSample<EulerAngleData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
