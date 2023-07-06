//
//  CompassViewController.swift
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
import STCore

final class CompassViewController: DemoNodeViewController<CompassDelegate, CompassView> {

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Compass_title"

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(calibrationImageTapped(_:)))

        mainView.calibrationImageView.isUserInteractionEnabled = true
        mainView.calibrationImageView.addGestureRecognizer(tap)
    }

    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.presenter.updateCompassValue(with: sample)
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
}

extension CompassViewController {

    @objc
    func calibrationImageTapped(_ sender: UITapGestureRecognizer) {
        presenter.startCalibration()
    }

    func updateCompass(with angle: Float, orientation: Orientation) {
        self.mainView.angleLabel.text = "\(angle)"
        self.mainView.directionLabel.text = orientation.description

        let rad = angle * (Float.pi / 180.0)
        self.mainView.needleImageView.transform = CGAffineTransform(rotationAngle: CGFloat(rad))
    }

    func showCalibrationIsNeeded() {

        let alertAction = AlertActionClosure(title: "ok", completion: {_ in })

        let controller = AlertPresenter(param: AlertConfiguration(image: UIImage(named: "img_compass_uncalibrated", in: Bundle.module, compatibleWith: nil),
                                                                  text: Localizer.Compass.Calibration.message.localized, callback: alertAction)).start()

        controller.modalPresentationStyle = .overFullScreen

        present(controller, animated: true)

        
        mainView.calibrationImageView.image = UIImage(named: "img_compass_uncalibrated", in: .module, compatibleWith: nil)
    }

    func showCalibrationDone() {

        dismiss(animated: true)

        mainView.calibrationImageView.image = UIImage(named: "img_compass_calibrated", in: .module, compatibleWith: nil)
    }
}

extension Orientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .north:
            return Localizer.Compass.Orientation.north.localized
        case .northEast:
            return Localizer.Compass.Orientation.northEst.localized
        case .east:
            return Localizer.Compass.Orientation.est.localized
        case .southEast:
            return Localizer.Compass.Orientation.southEst.localized
        case .south:
            return Localizer.Compass.Orientation.south.localized
        case .southWest:
            return Localizer.Compass.Orientation.southWest.localized
        case .west:
            return Localizer.Compass.Orientation.west.localized
        case .northWest:
            return Localizer.Compass.Orientation.northWest.localized
        }
    }
}
