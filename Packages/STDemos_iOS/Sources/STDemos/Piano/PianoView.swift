//
//  PianoView.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import SwiftUI

struct PianoView: View {
    var presenter: PianoPresenter
    var pianoKeyboard = PianoKeyboard()
    
    var body: some View {
        
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let keyHeight = height / CGFloat(PianoKeyboard.numberWhiteKeys)
            ZStack {
                //White Keys
                ForEach(
                    0..<PianoKeyboard.numberWhiteKeys,
                    id: \.self
                ) { key in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: width, height: keyHeight)
                        .border(Color.black, width:1)
                        .position(x: width*0.5, y: CGFloat(key) * keyHeight - keyHeight*0.5)
                }
                
                //Black Keys
                ForEach(
                    0..<PianoKeyboard.numberWhiteKeys,
                    id: \.self
                ) { key in
                    if (key != 2 && key != 6 && key != 9 && key != 13) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: width * 0.6, height: keyHeight*0.7)
                            .border(Color.white, width:1)
                            .position(x: width * 0.7, y: CGFloat(key+1) * keyHeight)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray)
                            .frame(width: width * 0.55, height: keyHeight*0.4)
                            .position(x: width * 0.725, y: CGFloat(key+1) * keyHeight)
                    }
                }
                
                //View for handling touch
                TouchView(delegate: TouchUIViewCheckPosition(geometry: geometry, presenter: presenter, pianoKeyboard: pianoKeyboard))
            }
            .frame(width: width, height: height)
            .border(Color.black, width:2)
        }
        .padding(4)
    }
}

class TouchUIViewCheckPosition {
    
    var prevKey: PianoKey?=nil
    var geometry: GeometryProxy?=nil
    var presenter: PianoPresenter
    var pianoKeyboard: PianoKeyboard
    
    init(geometry: GeometryProxy, presenter: PianoPresenter,pianoKeyboard : PianoKeyboard) {
        self.geometry = geometry
        self.presenter = presenter
        self.pianoKeyboard = pianoKeyboard
        self.pianoKeyboard.updateKeyDimensions(geometry: geometry)
    }
    
    func play(_ touch: CGPoint?) {
        if touch == nil {
            if prevKey != nil {
                presenter.stopPianoSound()
                prevKey?.pressed = false
            }
            prevKey = nil
        } else {
            //Search the Key
            
            //Before Black
            var foundBlack=false
            for black in pianoKeyboard.blackKeys {
                if black.checkIfContains(currentTouch: touch!) {
                    if prevKey == nil || prevKey?.sound != black.sound {
                        presenter.playPianoSound(key: black.sound)
                        prevKey?.pressed = false
                        prevKey = black
                        prevKey?.pressed = true
                    }
                    foundBlack=true
                    break
                }
            }
            
            //After White if it's not Black
            if foundBlack == false {
                for white in pianoKeyboard.whiteKeys {
                    if white.checkIfContains(currentTouch: touch!) {
                        if prevKey == nil || prevKey?.sound != white.sound {
                            presenter.playPianoSound(key: white.sound)
                            prevKey?.pressed = false
                            prevKey = white
                            prevKey?.pressed = true
                        }
                        break
                    }
                }
            }
        }
    }
}


struct TouchView: UIViewRepresentable {
    
    var delegate: TouchUIViewCheckPosition?
    
    func updateUIView(_ uiView: TouchUIView, context: Context) {}
    
    func makeUIView(context: Context) -> TouchUIView {
        let touchUIView = TouchUIView()
        touchUIView.InitializeDelegate(delegate: delegate)
        touchUIView.isMultipleTouchEnabled = false
        return touchUIView
    }
}


class TouchUIView: UIView {
    
    var delegate: TouchUIViewCheckPosition?
    
    var currentTouch: UITouch? = nil
    
    func updatePosition() {
        delegate?.play( currentTouch?.location(in: self))
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        currentTouch = touches.first
        updatePosition()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        currentTouch = touches.first
        updatePosition()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        currentTouch = nil
        updatePosition()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouch = nil
        updatePosition()
    }
    
    func InitializeDelegate(delegate: TouchUIViewCheckPosition?) {
        self.delegate = delegate
    }
}
