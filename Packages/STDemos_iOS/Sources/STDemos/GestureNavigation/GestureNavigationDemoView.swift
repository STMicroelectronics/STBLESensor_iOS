//
//  GestureNavigationDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 22/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

extension NavigationGestureType {
    
    var isPressEvent: Bool {
        switch self {
        case .SINGLE_PRESS, .DOUBLE_PRESS, .TRIPLE_PRESS, .LONG_PRESS : return true
        default: return false
        }
    }
    
    var compactDescription: String {
        switch self {
        case .UNDEFINED: return "Undefined"
        case .SWIPE_LEFT_TO_RIGHT: return "Swipe\nTo Right"
        case .SWIPE_RIGHT_TO_LEFT: return "Swipe\nTo Left"
        case .SWIPE_UP_TO_DOWN: return "Swipe\nTo Down"
        case .SWIPE_DOWN_TO_UP: return "Swipe\nTo Up"
        case .SINGLE_PRESS: return "Single\nPress"
        case .DOUBLE_PRESS: return "Double\nPress"
        case .TRIPLE_PRESS: return "Triple\nPress"
        case .LONG_PRESS: return "Long\nPress"
        case .ERROR: return "Error"
        }
    }
}



public struct GestureNavigationDemoView: View {
    
    @StateObject private var viewModel = GestureNavigationDemoViewModel()
    @State private var delegateHandler: GestureNavigationNodeBlueDelegateHandler?
    
    // Animation states
    @State private var alphaUp: Double = 0
    @State private var alphaDown: Double = 0
    @State private var alphaLeft: Double = 0
    @State private var alphaRight: Double = 0
    @State private var alphaButton: Double = 0
    
    @State private var moveUp: CGFloat = 0
    @State private var moveDown: CGFloat = 0
    @State private var moveLeft: CGFloat = 0
    @State private var moveRight: CGFloat = 0
    
    @State private var scaleUp: CGFloat = 1
    @State private var scaleDown: CGFloat = 1
    @State private var scaleLeft: CGFloat = 1
    @State private var scaleRight: CGFloat = 1
    @State private var scaleButton: CGFloat = 1
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        
        let gesture = viewModel.gestureWithTimeStamp
        let button =  viewModel.button
        
        ZStack {
            if viewModel.firstDataReceived {
                VStack(alignment: .center ,spacing: 24) {
                    
                    // Top Row (Up Arrow)
                    HStack {
                        Image("gesture_nav_arrow", bundle: STDemos.bundle)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .foregroundColor(SUIColorLayout.primary.color)
                            .opacity(alphaUp)
                            .scaleEffect(scaleUp)
                            .offset(y: moveUp)
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 32) {
                        Image("gesture_nav_arrow", bundle: STDemos.bundle)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .foregroundColor(SUIColorLayout.primary.color)
                            .rotationEffect(.degrees(270))
                            .opacity(alphaLeft)
                            .scaleEffect(scaleLeft)
                            .offset(x: moveLeft)
                        
                        ZStack {
                            Image(systemName: "hand.tap.fill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .foregroundColor(SUIColorLayout.stGray3.color)
                                .opacity(alphaButton)
                                .scaleEffect(scaleButton)
                            
                            Text(gesture.gesture.compactDescription)
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)
                        }
                        
                        Image("gesture_nav_arrow", bundle: STDemos.bundle)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .foregroundColor(SUIColorLayout.primary.color)
                            .rotationEffect(.degrees(90))
                            .opacity(alphaRight)
                            .scaleEffect(scaleRight)
                            .offset(x: moveRight)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Bottom Row (Down Arrow)
                    HStack {
                        Image("gesture_nav_arrow" ,bundle: STDemos.bundle)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .foregroundColor(SUIColorLayout.primary.color)
                            .rotationEffect(.degrees(180))
                            .opacity(alphaDown)
                            .scaleEffect(scaleDown)
                            .offset(y: moveDown)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .onChange(of: gesture) { _, gestureTimeStamp in
                    
                    let isPress = gestureTimeStamp.gesture.isPressEvent
                    
                    if isPress { triggerButtonAnimation() }
                }
                .onChange(of: button) { _, newButton in
                    switch newButton {
                    case .UP: triggerUpAnimation()
                    case .DOWN: triggerDownAnimation()
                    case .LEFT: triggerLeftAnimation()
                    case .RIGHT: triggerRightAnimation()
                    default: break
                    }
                }
                .onChange(of: gesture.gesture) { _, newGesture in
                    switch newGesture {
                    case .SWIPE_DOWN_TO_UP: triggerVerticalSwipeAnimation(isUp: true)
                    case .SWIPE_UP_TO_DOWN: triggerVerticalSwipeAnimation(isUp: false)
                    case .SWIPE_LEFT_TO_RIGHT: triggerHorizontalSwipeAnimation(isRight: true)
                    case .SWIPE_RIGHT_TO_LEFT: triggerHorizontalSwipeAnimation(isRight: false)
                    default: break
                    }
                }
            } else {
                Text("Waiting for gesture…")
                    .font(.title)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            delegateHandler = GestureNavigationNodeBlueDelegateHandler(viewModel: viewModel)
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
    
    private func triggerButtonAnimation() {
        withAnimation(.linear(duration: 0.4)) {
            alphaButton = 1.0
            scaleButton = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaButton = 0
                scaleButton = 1.0
            }
        }
    }
    
    private func triggerUpAnimation() {
        withAnimation(.linear(duration: 0.4)) {
            alphaUp = 1.0
            scaleUp = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaUp = 0
                scaleUp = 1.0
            }
        }
    }
    
    private func triggerDownAnimation() {
        withAnimation(.linear(duration: 0.4)) {
            alphaDown = 1.0
            scaleDown = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaDown = 0
                scaleDown = 1.0
            }
        }
    }
    
    private func triggerLeftAnimation() {
        withAnimation(.linear(duration: 0.4)) {
            alphaLeft = 1.0
            scaleLeft = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaLeft = 0
                scaleLeft = 1.0
            }
        }
    }
    
    private func triggerRightAnimation() {
        withAnimation(.linear(duration: 0.4)) {
            alphaRight = 1.0
            scaleRight = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaRight = 0
                scaleRight = 1.0
            }
        }
    }
    
    private func triggerVerticalSwipeAnimation(isUp: Bool) {
        let targetMove: CGFloat = isUp ? -32 : 32
        withAnimation(.linear(duration: 0.4)) {
            alphaDown = 1.0; alphaUp = 1.0
            moveDown = targetMove; moveUp = targetMove
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaDown = 0; alphaUp = 0
                moveDown = 0; moveUp = 0
            }
        }
    }
    
    private func triggerHorizontalSwipeAnimation(isRight: Bool) {
        let targetMove: CGFloat = isRight ? 32 : -32
        withAnimation(.linear(duration: 0.4)) {
            alphaLeft = 1.0; alphaRight = 1.0
            moveLeft = targetMove; moveRight = targetMove
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.linear(duration: 0.1)) {
                alphaLeft = 0; alphaRight = 0
                moveLeft = 0; moveRight = 0
            }
        }
    }
}

class GestureNavigationNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: GestureNavigationDemoViewModel
    
    init(viewModel: GestureNavigationDemoViewModel) {
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
        case let sample as FeatureSample<GestureNavigationData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
