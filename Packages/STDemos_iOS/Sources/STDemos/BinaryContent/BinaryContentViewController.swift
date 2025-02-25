//
//  BinaryContentViewController.swift
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
import STBlueSDK
import STCore
import JGProgressHUD

final public class BinaryContentViewController: DemoNodeNoViewController<BinaryContentDelegate> {
    
    let bleChunkSizeTextField = UITextField()
    
    let resultOperationTextField = UILabel()
    
    let fileNameTextField = UITextField()
    var saveToFileSV = UIStackView()
    
    let sendToBoardBtn = UIButton()
    var sendToBoardSV = UIStackView()
    
    let loadFromFileBtn = UIButton()
    
    let tableView = UITableView()
    
    let hud = JGProgressHUD()
    
    public override func configure() {
        super.configure()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.binaryContent.title
        
        presenter.load()
    }
    
    public override func configureView() {
        super.configureView()
        
        let fileManagementTitle = UILabel()
        fileManagementTitle.text = "File Management"
        TextLayout.bold.apply(to: fileManagementTitle)
        
        Buttonlayout.standardWithImage(image: UIImage(systemName: "square.and.arrow.up")).apply(to: loadFromFileBtn, text: "Load from File")
        let loadFromFileTap = UITapGestureRecognizer(target: self, action: #selector(loadFromFileBtnTapped(_:)))
        loadFromFileBtn.addGestureRecognizer(loadFromFileTap)
        
        let saveToFileBtn = UIButton()
        Buttonlayout.standardWithImage(image: UIImage(systemName: "square.and.arrow.down")).apply(to: saveToFileBtn, text: "Save to File")
        let saveToFileTap = UITapGestureRecognizer(target: self, action: #selector(saveToFileBtnTapped(_:)))
        saveToFileBtn.addGestureRecognizer(saveToFileTap)
        
        TextInputLayout.standard.apply(to: fileNameTextField)
        fileNameTextField.placeholder = "FileName.ext"
        fileNameTextField.text = "Binary.bin"
        
        saveToFileSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            fileNameTextField,
            saveToFileBtn
        ])
        
        Buttonlayout.standardWithImage(image: UIImage(systemName: "paperplane")).apply(to: sendToBoardBtn, text: "Send to Board")
        
        let sendToBoardTap = UITapGestureRecognizer(target: self, action: #selector(sendToBaoardBtnTapped(_:)))
        sendToBoardBtn.addGestureRecognizer(sendToBoardTap)
        
        
        TextInputLayout.numerical.apply(to: bleChunkSizeTextField)
        bleChunkSizeTextField.placeholder = "Chunck Size"
        bleChunkSizeTextField.text = "\(presenter.getBinaryContentMaxWriteLength())"
        
        let bleChuckTitle = UILabel()
        bleChuckTitle.text = "BLE Chunck"
        TextLayout.info.apply(to: bleChuckTitle)
        
        sendToBoardSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            bleChuckTitle,
            bleChunkSizeTextField,
            sendToBoardBtn
        ])
        
        
        resultOperationTextField.text = "Result operation"
        TextLayout.info.apply(to: resultOperationTextField)
        
        let commandView =  UIStackView.getVerticalStackView(withSpacing: 8, views: [
            fileManagementTitle,
            loadFromFileBtn,
            sendToBoardSV,
            saveToFileSV,
            resultOperationTextField
        ])
        
        let pnpLView = PnpLView()
        pnpLView.addSubview(tableView, constraints: [
            equal(\.leadingAnchor, constant: -16),
            equal(\.trailingAnchor, constant: 16),
            equal(\.topAnchor, constant: 0),
            equal(\.bottomAnchor, constant: 0)
        ])
        
        view.backgroundColor = .systemBackground
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            commandView,
            pnpLView
        ])
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    public override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        
        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)
        
        DispatchQueue.main.async { [weak self] in
            
            switch feature {
            case let featurePnPL as PnPLFeature:
                Logger.debug(text: featurePnPL.description(with: sample))
                self?.presenter.updatePnPL(with: featurePnPL)
                
            case let featureBinary as BinaryContentFeature:
                Logger.debug(text: featureBinary.description(with: sample))
                self?.presenter.updateBinaryContent(with: featureBinary)
                
            default:
                return
            }
        }
    }
}

extension BinaryContentViewController {
    
    func showMessage(message: String) {
        resultOperationTextField.isHidden = false
        resultOperationTextField.text = message
    }
    
    func hideMessage() {
        resultOperationTextField.isHidden = true
    }
    
    func showSendToBoardSection() {
        sendToBoardSV.isHidden = false
    }
    
    func hideSendToBoardSection() {
        sendToBoardSV.isHidden = true
    }
    
    func startReceivingIndicator() {
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.interactionType = .blockAllTouches
        hud.textLabel.text = "Receiving..."
        hud.detailTextLabel.text = "0 Bytes"
        hud.show(in: self.view)
    }
    
    func stopReceivingIndicator() {
        hud.dismiss(afterDelay: 0.5, animated: true) {
            self.hud.indicatorView = nil
            self.hud.textLabel.text = "Binary Content Received"
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    func updateReceivingIndicator(bytes: Int) {
        hud.detailTextLabel.text = "\(bytes) Bytes"
    }
    
    func showSaveToFileSV() {
        saveToFileSV.isHidden = false
    }
    
    func hideSaveToFileSV() {
        saveToFileSV.isHidden = true
    }
    
    func startSendingIndicator() {
        
        hud.indicatorView = JGProgressHUDPieIndicatorView()
        hud.interactionType = .blockAllTouches
        
        hud.progress = 0.0
        hud.textLabel.text = "Sending..."
        hud.detailTextLabel.text = "0% Complete"
        hud.show(in: self.view)
    }
    
    func updateSendingIndicator(fraction: Float) {
        hud.progress =  fraction
        hud.detailTextLabel.text = "\(round(fraction * 1000)/10.0)% Complete"
        
    }
    
    func stopSendingIndicator() {
        hud.dismiss(afterDelay: 0.5, animated: true) {
            self.hud.indicatorView = nil
            self.hud.textLabel.text = "Binary Content Sent"
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @objc
    func loadFromFileBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.loadFromFile()
    }
    
    @objc
    func saveToFileBtnTapped(_ sender: UITapGestureRecognizer) {
        presenter.saveToFile(fileName: fileNameTextField.text)
    }
    
    @objc
    func sendToBaoardBtnTapped(_ sender: UITapGestureRecognizer) {
        
        var chunk: Int = 20
        
        if let text = bleChunkSizeTextField.text {
            chunk = Int(text) ?? 20
        }
        
        presenter.sendToBoard(bleChunkWriteSize: chunk)
    }
}
