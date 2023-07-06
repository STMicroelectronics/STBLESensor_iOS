//
//  LevelPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class LevelPresenter: DemoPresenter<LevelViewController> {
    private static let PITCH_ROLL_FORMAT:String = {
        return  NSLocalizedString(
            "Offset: %.2f %@",
            tableName: nil,
            bundle: .module,
            value: "Offset: %.2f %@",
            comment: "Offset: %.2f %@")
    }()
}

// MARK: - LevelViewControllerDelegate
extension LevelPresenter: LevelDelegate {

    func load() {
        demo = .level
        
        demoFeatures = param.node.characteristics.features(with: Demo.level.features)
        
        view.configureView()
    }
    
    func updateLevelUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<EulerAngleData>,
           let data = sample.data {
            if let pitch = data.pitch.value {
                if let uom = data.pitch.uom {
                    view.mPitch = pitch
                    view.pitchRollView.pitchOffsetLabel.text = String(format: LevelPresenter.PITCH_ROLL_FORMAT, pitch, uom)
                    rotate(imageView: view.pitchRollView.pitchImageView, degrees: CGFloat(pitch))
                }
            }
            if let roll = data.roll.value {
                if let uom = data.roll.uom {
                    view.mRoll = roll
                    view.pitchRollView.rollOffsetLabel.text = String(format: LevelPresenter.PITCH_ROLL_FORMAT, roll, uom)
                    rotate(imageView: view.pitchRollView.rollImageView, degrees: CGFloat(roll))
                }
            }
            showPlanarLevel()
        }
    }
    
    func changeLevelMeasure() {
        var actions: [UIAlertAction] = []
        
        let levelSelection = view.levelSelection
            
        for i in 0..<levelSelection.count {
            actions.append(UIAlertAction.genericButton(levelSelection[i]) { [weak self] _ in
                self?.view.levelSelectionView.selectionLabel.text = levelSelection[i]
                self?.view.currentLevelSelection = i
            })
        }
        actions.append(UIAlertAction.cancelButton())
        UIAlertController.presentAlert(from: view.self, title: "Select Measure to Display", actions: actions)
        
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    func setZero() {
        view.mZeroRoll = view.mRoll
        view.mZeroPitch = view.mPitch
    }
    
    func resetZero() {
        view.mZeroPitch = 0.0
        view.mZeroRoll = 0.0
    }
    
    private func showPlanarLevel(){
        let roll = view.mRoll - view.mZeroRoll
        let pitch = view.mPitch - view.mZeroPitch
        
        let width = CGFloat(view.levelGraphView.mainView.frame.width / 2)
        let height = CGFloat(view.levelGraphView.mainView.frame.height / 2)
        
        var deltaY: Float = 0.0
        var deltaX: Float = 0.0
        
        if(view.currentLevelSelection == 0) {
            deltaY = Float(height * sin(deg2rad(Double(roll))))
            deltaX = Float(width * sin(deg2rad(Double(pitch))))
        } else if (view.currentLevelSelection == 1) {
            deltaY = 0
            deltaX = Float(width * sin(deg2rad(Double(pitch))))
        } else {
            deltaY = Float(height * sin(deg2rad(Double(roll))))
            deltaX = 0
        }

        view.levelGraphView.circle.transform = view.levelGraphView.circle.transform.translatedBy(x: CGFloat(deltaX), y: CGFloat(deltaY))
        view.levelGraphView.circle.transform = CGAffineTransform(translationX: CGFloat(deltaX), y: CGFloat(deltaY))
            
    }
    
    
    private func rotate(imageView: UIImageView, degrees: CGFloat) {
        let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
            return degrees / 180.0 * CGFloat.pi
        }
        imageView.transform =  CGAffineTransform(rotationAngle: degreesToRadians(degrees))
    }

    private func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}
