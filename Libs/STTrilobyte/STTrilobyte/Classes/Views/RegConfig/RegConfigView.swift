//
//  RegConfigView.swift
//  trilobyte-lib-ios
//
//  Created by STMicroelectronics MEMS on 12/12/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import Foundation

enum VirtualSensorType {
    case Unknown
    case None
    case MLCVirtualSensor
    case FSMVirtualSensor
    case Both
}

protocol RegConfigViewDelegate: class {
    func ucfPickerUserRequestFile()
}

class RegConfigView: UIView {
    
    @IBOutlet weak var labelStackView: UIStackView!
    
    var type: VirtualSensorType = .Unknown
    private (set) var parser: UcfParser?
    
    var regConfig: String = ""
    var ucfFilename: String = ""

    weak var delegate: RegConfigViewDelegate?

    @IBOutlet weak var ucfFileButton: UIButton!

    @IBAction func ucfFileButtonPressed(_ sender: UIButton) {
        delegate?.ucfPickerUserRequestFile()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadView(type: VirtualSensorType, parser: UcfParser) {
        // Check valid ucf / sensor types
        if type == .MLCVirtualSensor {
            if (parser.type == .MLCVirtualSensor || parser.type == .Both) {
                self.parser = parser
                configureView(ucfParsed: parser)
            } else {
                ModalService.showWarningMessage(with: "err_wrong_mlc_file_selected".localized())
            }
        } else if type == .FSMVirtualSensor {
            if (parser.type == .FSMVirtualSensor || parser.type == .Both) {
                self.parser = parser
                configureView(ucfParsed: parser)
            } else {
                ModalService.showWarningMessage(with: "err_wrong_fsm_file_selected".localized())
            }
        }
    }
    
    func initView(type: VirtualSensorType, regConfig: String, ucfFilename: String, labels: String) {
        
        self.type = type
        
        let parser = UcfParser(type: type, regConfig: regConfig, ucfFilename: ucfFilename, labels: labels)
        
        loadView(type: type, parser: parser)
    }
    
    func configureView(type: VirtualSensorType, labelMapper: ValueLabelMapper, ucfFilename: String) {
        
        if (!ucfFilename.isEmpty) {
            ucfFileButton.setTitle(ucfFilename, for: .normal)
        }
        
        labelStackView.removeAllArrangedSubviews()
        
        let nAlgos = type == .MLCVirtualSensor ? 8 : 16
        let iOffset = type == .MLCVirtualSensor ? 0 : 1
        let expandButtonHidden = type == .MLCVirtualSensor ? false : true
        
        for i in 0..<nAlgos {
            let algoNameNumberFormat = type == .MLCVirtualSensor ? "DecTree%1d" : (i < 10 ? "Program%1d" : "Program%2d")
            let algoDefaultNameFormat = type == .MLCVirtualSensor ? "DT%1d" : (i < 10 ? "FSM%1d" : "FSM%2d")
            let algoLabelView: AlgoLabelView = AlgoLabelView.createFromNib()
            algoLabelView.initLabelStackPanel(index: ValueLabelMapper.RegisterIndex(i), valueMapper: labelMapper)
            
            algoLabelView.setAlgoNumber(name: String(format: algoNameNumberFormat, i + 1))
            algoLabelView.setAlgoName(name: labelMapper.algorithmName(register: ValueLabelMapper.RegisterIndex(i + iOffset)) ?? String(format: algoDefaultNameFormat, i + 1))
            algoLabelView.setExpandButtonHidden(state: expandButtonHidden)
            
            labelStackView.addArrangedSubview(algoLabelView)
        }
    }
    
    func configureView(ucfParsed: UcfParser) {
        configureView(type: ucfParsed.type, labelMapper: ucfParsed.labelMapper, ucfFilename: ucfParsed.ucfFilename)
    }
    
    func parseUcfFile(ucf: URL) {
        
        guard let parser = UcfParser(ucf: ucf) else {
            ModalService.showWarningMessage(with: "err_wrong_ucf_file_selected".localized())
            return
        }
        
        loadView(type: type, parser: parser)
    }
}
