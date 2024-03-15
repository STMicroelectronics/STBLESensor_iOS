//
//  RegConfigView.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

enum VirtualSensorType {
    case Unknown
    case None
    case MLCVirtualSensor
    case FSMVirtualSensor
    case Both
}

protocol RegConfigViewDelegate: AnyObject {
    func ucfPickerUserRequestFile()
}


class RegConfigView: UIView {
    
    @IBOutlet weak var configFileTitle: UILabel!
    @IBOutlet weak var labelsTitle: UILabel!
    
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var ucfFileButton: UIButton!
    
    var type: VirtualSensorType = .Unknown
    private (set) var parser: UcfParser?
    
    var regConfig: String = ""
    var ucfFilename: String = ""

    weak var delegate: RegConfigViewDelegate?
    
    @IBAction func ucfFileButtonPressed(_ sender: UIButton) {
        delegate?.ucfPickerUserRequestFile()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        TextLayout.title2.apply(to: configFileTitle)
        TextLayout.title2.apply(to: labelsTitle)
        
        Buttonlayout.standard.apply(to: ucfFileButton)
    }
    
    func loadView(type: VirtualSensorType, parser: UcfParser) {
        // Check valid ucf / sensor types
        if type == .MLCVirtualSensor {
            if (parser.type == .MLCVirtualSensor || parser.type == .Both) {
                self.parser = parser
                configureView(ucfParsed: parser)
            } else {
                ModalService.showWarningMessage(with: "The selected ucf configuration does not enable the MLC")
            }
        } else if type == .FSMVirtualSensor {
            if (parser.type == .FSMVirtualSensor || parser.type == .Both) {
                self.parser = parser
                configureView(ucfParsed: parser)
            } else {
                ModalService.showWarningMessage(with: "The selected ucf configuration does not enable the FSM")
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
            ModalService.showWarningMessage(with: "The selected ucf configuration cannot be parsed correctly")
            return
        }
        
        loadView(type: type, parser: parser)
    }
}
