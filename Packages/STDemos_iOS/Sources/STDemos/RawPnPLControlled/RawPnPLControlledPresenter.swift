//
//  RawPnPLControlledPresenter.swift
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

final class RawPnPLControlledPresenter: DemoPresenter<RawPnPLControlledViewController> {
    internal static let outputStreamKey = "outputStream"
    
    public var rawPnPLEntries: [RawPnPLStreamEntry] = []
    public var pnplPresenter: PnpLPresenter?
    
    var firmwareDB: Firmware?
    var pnpLMaxWriteLength: Int = 20
}

// MARK: - RawPnPLControlledViewControllerDelegate
extension RawPnPLControlledPresenter: RawPnPLControlledDelegate {
    
    func requestStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,  maxWriteLength: pnpLMaxWriteLength, to: self.param.node)
    }
    
    func load() {
        
        demoFeatures = param.node.characteristics.features(with: Demo.rawPnPLControlled.features)
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: param.node)
        }
        
        //Search if there is a max write for PnPL feature
        if firmwareDB != nil {
            for feature in demoFeatures {
                if feature is PnPLFeature {
                    if  let pnpLMaxWriteLength = firmwareDB?.characteristics?.first(where: { char in char.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
                        if pnpLMaxWriteLength > param.node.mtu {
                            self.pnpLMaxWriteLength = param.node.mtu
                        } else {
                            self.pnpLMaxWriteLength = pnpLMaxWriteLength
                        }
                    }
                }
            }
        }
        
        view.configureView()
        
        if let dtmi = BlueManager.shared.dtmi(for: param.node) {
            initRawStreamLabelViewModel(with: dtmi)
        }
    }
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature) {
        if let pnplFeature = feature as? PnPLFeature {
            guard let sample = pnplFeature.sample,
                  let response = sample.data?.response,
                  let device = response.devices.first else { return }
            if let feature = demoFeatures.first(where: { type(of: $0) == RawPnPLControlledFeature.self }) {
                if let rawPnPLControlledFeature = feature as? RawPnPLControlledFeature {
                    rawPnPLControlledFeature.decodePnPLBoardResponseStreams(components: device.components)
                }
            }
        }
    }
    
    func newRawPnPLControlledSample(with sample: AnyFeatureSample?, and feature: Feature) {
        Logger.debug(text: feature.description(with: sample))
        
        if let rawPnplFeature = feature as? RawPnPLControlledFeature {
            if let sample = rawPnplFeature.sample {
                rawPnPLEntries = rawPnplFeature.extractBleStreamInfo(sample: sample)

                self.pnplPresenter?.director?.updateVisibleCells(with: [
                    CodeValue<String>(keys: [RawPnPLControlledPresenter.outputStreamKey],
                                      value: "\(rawPnPLEntries.description)")
                ])
            }
        }
    }
    
    func initRawStreamLabelViewModel(with dtmi: FirmwareDtmi) {
        let pnplPresenter = Demo.pnpLike.presenter(
            with: self.param.node,
            param: PnplDemoConfiguration(contents: dtmi.contents.rawPnPLControlled)
        )
        
        let pnplController = pnplPresenter.start()
        
        pnplController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addChild(pnplController)
        view.view.addSubview(pnplController.view, constraints: UIView.fitToSuperViewConstraints)
        
        if let pnplPresenter = pnplPresenter as? PnpLPresenter {
            self.pnplPresenter = pnplPresenter
            
            if let director = pnplPresenter.director {
                director.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                                  type: .fromClass,
                                  bundle: STUI.bundle)
            }
            
            let streamLabelViewModel = LabelViewModel(
                param: CodeValue<String>(
                    keys: [ RawPnPLControlledPresenter.outputStreamKey ],
                    value: " - - - \n\n\n\n"),
                layout: Layout.info
            )
            
            pnplPresenter.director?.elements.append(ContainerCellViewModel(childViewModel: streamLabelViewModel, layout: Layout.info))
            pnplPresenter.director?.reloadData()
        }
    }
}
