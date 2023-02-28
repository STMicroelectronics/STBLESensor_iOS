//
//  BankStatusViewController.swift
//  W2STApp

import Foundation
import UIKit
import BlueSTSDK
import BlueSTSDK_Gui
import PKHUD

@available(iOS 13.0, *)
class BankStatusViewController: UIViewController {

    @IBOutlet weak var currentFlashMemoryBankTitle: UILabel!
    @IBOutlet weak var onArrow1Touched: UIImageView!
    @IBOutlet weak var currentFlashMemoryBankDescription: UILabel!
    @IBOutlet weak var firmwareCurrentlyRunningTitle: UILabel!
    @IBOutlet weak var firmwareCurrentlyRunning: UILabel!
    
    @IBOutlet weak var fwUpdateAvailableSV: UIStackView!
    @IBOutlet weak var fwUpdate: UILabel!
    @IBOutlet weak var fwUpdateChangelog: UILabel!
    
    @IBOutlet weak var otherFlashMemoryBankTitle: UILabel!
    @IBOutlet weak var onArrow2Touched: UIImageView!
    @IBOutlet weak var otherFlashMemoryBankDescription: UILabel!
    @IBOutlet weak var firmwareFlashedOnOtherBankTitle: UILabel!
    @IBOutlet weak var firmwareFlashedOnOtherBank: UILabel!
    @IBOutlet weak var listOfCompatibleFwSV: UIStackView!
    @IBOutlet weak var listOfCompatibleFirmwareTitle: UILabel!
    @IBOutlet weak var selectedFwDescriptionSV: UIStackView!
    @IBOutlet weak var selectedFwDescription: UILabel!
    @IBOutlet weak var downloadAndFlashFirmwareBtn: UIButton!
    @IBOutlet weak var swapToThisBankBtn: UIButton!
    private let compatibleFirmwareField = SelectCellView()
    
    public var flashStatus: BankStatusResponse
    public var node: BlueSTSDKNode
    public let currentBank: Int
    
    private var currentFlashMemoryBankFirmwareCatalog: Firmware? = nil
    private var otherFlashMemoryBankFirmwareCatalog: Firmware? = nil
    private var currentFlashMemoryBankUpdateAvailable: Firmware? = nil
    private var otherFlashMemoryBankCompatibleFirmwaresCatalog: [Firmware]? = nil
    
    private var fwToFlash: Firmware? = nil
    
    private var selectedFileName: String = ""
    private var selectedFileUrl: String = ""

    
    init(node: BlueSTSDKNode, flashStatus: BankStatusResponse) {
        self.node = node
        self.flashStatus = flashStatus
        self.currentBank = flashStatus.currentBank
        super.init(nibName: "BankStatusViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var extFeature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    
    @objc
    private func dismissModal() {
        navigationController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Flash Bank Status"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        initialSetupMemoryFlashLayout()
        retrieveAllAssociatedFirmwares()
        findPossibleFwCurrentUpdate()
        filterOtherFlashMemoryBankCompatibleFirmwaresCatalog()
        removeFwsIfUrlIsNull()
        setupFirmwareInfoOnLayout()
    }
    
    private func initialSetupMemoryFlashLayout(){
        
        compatibleFirmwareField.text = "Not selected."
        
        listOfCompatibleFwSV.addArrangedSubview(compatibleFirmwareField)
        
        compatibleFirmwareField.onTap { [weak self] _ in
            self?.showTemplatesChoice()
        }
        
        /** Handling expansing and reducing text in UILabesl */
        let currentFlashMemoryBankDescriptionTap = UITapGestureRecognizer(target: self, action: #selector(currentFlashMemoryBankDescriptionTapped))
        onArrow1Touched.isUserInteractionEnabled = true
        onArrow1Touched.addGestureRecognizer(currentFlashMemoryBankDescriptionTap)
        let otherFlashMemoryBankDescriptionTap = UITapGestureRecognizer(target: self, action: #selector(otherFlashMemoryBankDescriptionTapped))
        onArrow2Touched.isUserInteractionEnabled = true
        onArrow2Touched.addGestureRecognizer(otherFlashMemoryBankDescriptionTap)
        
        downloadAndFlashFirmwareBtn.addTarget(self, action: #selector(onDownloadAndFlashFirmwareTapped), for: .touchUpInside)
        swapToThisBankBtn.addTarget(self, action: #selector(onBankSwapTapped), for: .touchUpInside)
        
        currentFlashMemoryBankTitle.text = "Current Bank [\(currentBank)]"
    }
    
    private func retrieveAllAssociatedFirmwares(){
        if(currentBank==1){
            currentFlashMemoryBankFirmwareCatalog = findFirmwareCatalog(bleFwId: Int(flashStatus.fwId1.dropFirst(2), radix: 16)!)
            otherFlashMemoryBankFirmwareCatalog = findFirmwareCatalog(bleFwId: Int(flashStatus.fwId2.dropFirst(2), radix: 16)!)
            otherFlashMemoryBankCompatibleFirmwaresCatalog = findCompatibleFirmwareCatalog(bleFwId: Int(flashStatus.fwId2.dropFirst(2), radix: 16)!)
        } else {
            currentFlashMemoryBankFirmwareCatalog = findFirmwareCatalog(bleFwId: Int(flashStatus.fwId2.dropFirst(2), radix: 16)!)
            otherFlashMemoryBankFirmwareCatalog = findFirmwareCatalog(bleFwId: Int(flashStatus.fwId1.dropFirst(2), radix: 16)!)
            otherFlashMemoryBankCompatibleFirmwaresCatalog = findCompatibleFirmwareCatalog(bleFwId: Int(flashStatus.fwId1.dropFirst(2), radix: 16)!)
        }
    }
    
    private func findPossibleFwCurrentUpdate(){
        if(otherFlashMemoryBankCompatibleFirmwaresCatalog != nil){
            if(currentFlashMemoryBankFirmwareCatalog != nil){
                otherFlashMemoryBankCompatibleFirmwaresCatalog?.forEach{ compatibleFw in
                    if(compatibleFw.name == currentFlashMemoryBankFirmwareCatalog!.name){
                        if(compatibleFw.version > currentFlashMemoryBankFirmwareCatalog!.version){
                            setSelectedFirmware(fw: compatibleFw)
                            currentFlashMemoryBankUpdateAvailable = compatibleFw
                        }
                    }
                }
            }
        }
    }
    
    private func setSelectedFirmware(fw: Firmware){
        fwToFlash = fw
        compatibleFirmwareField.text = "\(fw.name) v\(fw.version)"
        downloadAndFlashFirmwareBtn.setTitle("Install \(fw.name) v\(fw.version)", for: .normal)
        selectedFileName = "\(fw.name)v\(fw.version)"
        selectedFileUrl = "\(fw.fota.url ?? " ")"
        selectedFwDescription.text = "\(fw.description ?? " ")"
        selectedFwDescriptionSV.isHidden = false
        downloadAndFlashFirmwareBtn.isEnabled = true
    }
    
    private func filterOtherFlashMemoryBankCompatibleFirmwaresCatalog(){
        if(otherFlashMemoryBankCompatibleFirmwaresCatalog != nil){
            if(otherFlashMemoryBankFirmwareCatalog != nil){
                var i = 0
                otherFlashMemoryBankCompatibleFirmwaresCatalog?.forEach{ compatibleFw in
                    if(compatibleFw.name == otherFlashMemoryBankFirmwareCatalog!.name){
                        if(compatibleFw.version <= otherFlashMemoryBankFirmwareCatalog!.version){
                            otherFlashMemoryBankCompatibleFirmwaresCatalog!.remove(at: i)
                        }
                    }
                    i += 1
                }
            }
        }
    }
    
    private func removeFwsIfUrlIsNull(){
        if(otherFlashMemoryBankCompatibleFirmwaresCatalog != nil){
            let firmwaresFiltered = otherFlashMemoryBankCompatibleFirmwaresCatalog?.filter { $0.fota.url != nil  }
            otherFlashMemoryBankCompatibleFirmwaresCatalog = firmwaresFiltered
        }
    }
    
    private func setupFirmwareInfoOnLayout(){
        if(currentFlashMemoryBankFirmwareCatalog != nil){
            firmwareCurrentlyRunning.text = "\(currentFlashMemoryBankFirmwareCatalog!.name) v\(currentFlashMemoryBankFirmwareCatalog!.version)"
        }
        if(otherFlashMemoryBankFirmwareCatalog != nil){
            firmwareFlashedOnOtherBank.text = "\(otherFlashMemoryBankFirmwareCatalog!.name) v\(otherFlashMemoryBankFirmwareCatalog!.version)"
        }
        if(currentFlashMemoryBankUpdateAvailable != nil){
            fwUpdateAvailableSV.isHidden = false
            fwUpdate.text = "\(currentFlashMemoryBankUpdateAvailable!.name) v\(currentFlashMemoryBankUpdateAvailable!.version)"
            fwUpdateChangelog.text = "Changelog:\n\(currentFlashMemoryBankUpdateAvailable!.changelog ?? " ")"
        }
        if(otherFlashMemoryBankFirmwareCatalog==nil){
            swapToThisBankBtn.isHidden = true
        }
    }
    
    private func showTemplatesChoice() {
        if(otherFlashMemoryBankCompatibleFirmwaresCatalog != nil){
            var actions: [UIAlertAction] = otherFlashMemoryBankCompatibleFirmwaresCatalog!.map { fw in
                UIAlertAction.genericButton("\(fw.name) v\(fw.version)") { [weak self] _ in
                    self?.setSelectedFirmware(fw: fw)
                }
            }
            actions.append(UIAlertAction.cancelButton())
            
            UIAlertController.presentActionSheet(from: self, title: "Select Firmware".localizedFromGUI, message: nil, actions: actions)
        }
    }
    
    /** Find Actual Firmware in Catalog */
    public func findFirmwareCatalog(bleFwId: Int) -> Firmware? {
        let catalogService = CatalogService()
        let catalog = catalogService.currentCatalog()
        if(catalog != nil){
            return catalogService.getCurrentFwDetailsNode(catalog: catalog!, device_id: Int(node.typeId), bleFwId: bleFwId)
        } else {
            return nil
        }
    }
    
    /** Find Other Compatible Firmware in Catalog */
    public func findCompatibleFirmwareCatalog(bleFwId: Int) -> [Firmware]? {
        let catalogService = CatalogService()
        let catalog = catalogService.currentCatalog()
        if(catalog != nil){
            return catalogService.getCompatibleFirmwaressNode(catalog: catalog!, device_id: Int(node.typeId), bleFwId: bleFwId)
        } else {
            return nil
        }
    }
    
    /** Click on Bank Swap Button */
    @objc func onBankSwapTapped(sender: UIButton!) {
        if let feature = extFeature {
            feature.enableNotification()
            feature.sendCommand(ECCommandType.bankSwap)
            view.makeToast("The Board will reboot after the disconnection.")
            navigationController?.dismiss(animated: true)
        }
    }
    
    /** Handling expansing and reducing text in current flash memory bank description */
    @objc func currentFlashMemoryBankDescriptionTapped(sender: UIButton!) {
        if(currentFlashMemoryBankDescription.isHidden){
            currentFlashMemoryBankDescription.isHidden = false
            onArrow1Touched.image = UIImage(systemName: "xmark")
        } else {
            currentFlashMemoryBankDescription.isHidden = true
            onArrow1Touched.image = UIImage(systemName: "info.circle.fill")
        }
    }

    /** Handling expansing and reducing text in other flash memory bank description */
    @objc func otherFlashMemoryBankDescriptionTapped(sender: UIButton!) {
        if(otherFlashMemoryBankDescription.isHidden){
            otherFlashMemoryBankDescription.isHidden = false
            onArrow2Touched.image = UIImage(systemName: "xmark")
        } else {
            otherFlashMemoryBankDescription.isHidden = true
            onArrow2Touched.image = UIImage(systemName: "info.circle.fill")
        }
    }
    
    /** Click on Download And Flash Firmware Button */
    @objc func onDownloadAndFlashFirmwareTapped(sender: UIButton!) {
        HUD.show(.progress, onView: self.view)
        let fwDownloadManager = FwDownloadManager(fileName: selectedFileName, url: selectedFileUrl)
        fwDownloadManager.downloadFile() { (downloadedFwPath) -> () in
            print("[CALLBACK] \(downloadedFwPath ?? "Cannot download the firmware")")
            //DispatchQueue.main.async {
                HUD.hide()
                if(downloadedFwPath != nil){
                    let vc = BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: self.node, requireAddress: false, fwLocalUrl: URL(string: downloadedFwPath!))
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.view.makeToast("Cannot download the firmware")
                }
            //}
        }
    }
}

/** View that allows user to select a compatible firmware */
class SelectFirmwareCellView: BaseView {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
    var text: String = "" {
        didSet {
            titleLabel.text = text
        }
    }
    
    override func configureView() {
        super.configureView()
        
        let line = UIView()
        line.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(line, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor),
            equalDimension(\.heightAnchor, to: 1 / UIScreen.main.scale)
        ])
        
        let stack = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            titleLabel,
            imageView
        ])
        stack.alignment = .center
        
        imageView.image = UIImage.namedFromGUI("icon_arrow_down")
        imageView.setDimensionContraints(width: 16, height: 16)
        
        addSubviewAndFit(stack, top: 0, trailing: 0, bottom: 16, leading: 0)
    }
}
