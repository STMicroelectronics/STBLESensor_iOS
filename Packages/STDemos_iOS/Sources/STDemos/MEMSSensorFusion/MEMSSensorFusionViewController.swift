//
//  MEMSSensorFusionViewController.swift
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
import SceneKit
import GLKit
import STCore

final class MEMSSensorFusionViewController: DemoNodeViewController<MEMSSensorFusionDelegate, MEMSSensorFusionView> {
    
    private static let SCENE_MODEL_FILE = "art.scnassets/cubeModel.scn"
    private static let SCENE_MODEL_NAME = "Cube"
    private static let CUBE_DEFAULT_SCALE = Float(1.5)
    
    var proximityIsEnabled = false
    var resetPosition = false
    var mResetQuat = GLKQuaternionIdentity
    var m3DScene: SCNScene?
    var m3DCube: SCNNode?
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.memsSensorFusion.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        init3DCubeScene()
        
        let calibrationBtnTap = UITapGestureRecognizer(target: self, action: #selector(calibrationBtnTapped(_:)))
        mainView.calibrationBtn.isUserInteractionEnabled = true
        mainView.calibrationBtn.addGestureRecognizer(calibrationBtnTap)
        
        let resetBtnTap = UITapGestureRecognizer(target: self, action: #selector(resetBtnTapped(_:)))
        mainView.resetBtn.isUserInteractionEnabled = true
        mainView.resetBtn.addGestureRecognizer(resetBtnTap)
        
        let proximityBtnTap = UITapGestureRecognizer(target: self, action: #selector(proximityBtnTapped(_:)))
        mainView.proxymityBtn.isUserInteractionEnabled = true
        mainView.proxymityBtn.addGestureRecognizer(proximityBtnTap)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateSensorFusionValue(with: sample)
        }
    }
    
    override func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {

        if feature.type.mask == response.featureMask,
           let response = response as? AutoConfigurationCommandResponse {
            Logger.debug(text: "\(response.description) (\(response.data.extractUInt8(fromOffset: 0)))")
            Logger.debug(text: "\(response.status == .configured ? "CONFIGURED" : "NOT CONFIGURED")")

            DispatchQueue.main.async { [weak self] in

                guard let self = self else { return }
                self.presenter.updateCalibration(with: response.status)
            }
        }
    }

    private func init3DCubeScene(){
        m3DScene = SCNScene(named: MEMSSensorFusionViewController.SCENE_MODEL_FILE)
        guard let m3DScene = m3DScene else { return }
        
        m3DCube = m3DScene.rootNode.childNode(withName: MEMSSensorFusionViewController.SCENE_MODEL_NAME, recursively: true)
        
        guard let m3DCube = m3DCube else { return }
        
        setCubeScaleFactor(MEMSSensorFusionViewController.CUBE_DEFAULT_SCALE)
        mainView.m3DCubeView.prepare(m3DCube, shouldAbortBlock: nil)
        mainView.m3DCubeView.scene = m3DScene
        
        if #available(iOS 13, *){
            mainView.m3DCubeView.backgroundColor = UIColor.systemBackground
        }
    }
    
    /// Change the cube scale factor
    func setCubeScaleFactor(_ scale:Float){
        m3DCube?.scale = SCNVector3Make(scale,scale,scale)
    }
    
}

extension MEMSSensorFusionViewController {
    @objc
    func calibrationBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startCalibration()
    }
    
    @objc
    func resetBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startReset()
    }
    
    @objc
    func proximityBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.startStopProxymity()
    }
    
    func showCalibrationIsNeeded() {
        let alertAction = AlertActionClosure(
            title: "ok",
            completion: {_ in }
        )

        let controller = AlertPresenter(
            param: AlertConfiguration(
                image: UIImage(named: "img_compass_uncalibrated", in: Bundle.module, compatibleWith: nil),
                text: Localizer.Compass.Calibration.message.localized,
                callback: alertAction
            )
        ).start()

        controller.modalPresentationStyle = .overFullScreen

        present(controller, animated: true)

        
        mainView.calibrationBtn.setImage(
            UIImage(named: "img_compass_uncalibrated", in: .module, compatibleWith: nil),
            for: .normal
        )
    }

    func showCalibrationDone() {

        dismiss(animated: true)

        mainView.calibrationBtn.setImage(
            UIImage(named: "img_compass_calibrated", in: .module, compatibleWith: nil),
            for: .normal
        )
    }
    
    func showRestDialog(node: NodeType) {
        let dialogMessage = getDialogMessage(baseOnNode: node)
        let boardSchemaImage = getBoardSchemaImage(baseOnNodeType: node)

        let alertAction = AlertActionClosureBool(
            title: "ok",
            completion: { isDialogClosed in
                if(isDialogClosed){
                    self.resetPosition = true
                }
            }
        )

        let controller = CallbackAlertPresenter (
            param: CallbackAlertConfiguration (
                image: boardSchemaImage,
                text: dialogMessage,
                callback: alertAction
            )
        ).start()

        controller.modalPresentationStyle = .overFullScreen

        present(controller, animated: true)
    }
    
}

extension MEMSSensorFusionViewController {
    private func getDialogMessage(baseOnNode node: NodeType) -> String {
        switch node {
        case .nucleo,.blueCoin,.sensorTile,.sensorTileBox:
            return "Keep the board as shown in the image"
        default:
            return "Keep the board horizontaly"
        }
    }
    
    func getBoardSchemaImage(baseOnNodeType nodeType: NodeType) -> UIImage? {
        guard let schemaImageName = nodeType.schemaImageName else { return nil }
        return UIImage(named: schemaImageName, in: STUI.bundle, compatibleWith: nil)
    }
}
