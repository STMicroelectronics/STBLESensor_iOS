import Foundation
import BlueSTSDK

public class STM32WBAOtaViewController : UIViewController, BlueSTSDKDemoViewProtocol{
    public var node: BlueSTSDKNode!
    
    public var menuDelegate: BlueSTSDKViewControllerMenuDelegate?

    static let FORMATTING_MSG:String = {
        let bundle = Bundle(for: STM32WBAOtaViewController.self);
        return NSLocalizedString("Formatting...", tableName: nil,
                                 bundle: bundle,
                                 value: "Formatting...",
                                 comment: "Formatting...");
    }();

    @IBOutlet weak var mUploadView: UIView!
    @IBOutlet weak var mUploadProgressView: UIProgressView!
    @IBOutlet weak var mUploadProgressLabel: UILabel!
    @IBOutlet weak var mUploadStatusProgress: UILabel!
    
    @IBOutlet weak var selectedDocument: UILabel!

    @IBOutlet weak var mNumSectorText: UITextField!
    
    @IBOutlet weak var mAddressText: UITextField!
    
    @IBOutlet weak var mFwTypeSelector: UISegmentedControl!
    
    @IBOutlet weak var mStartUploadButton: UIButton!
    
    private var firmware: URL? = nil

    private var mFwUpgradeConsole:BlueSTSDKFwUpgradeConsoleSTM32WBA? = nil
    private var mProgresViewController:BlueSTSDKFwUpgradeProgressViewController!
    private var mDownloadProgressViewController:BlueSTSDKDownloadFileViewController!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        mProgresViewController =
            BlueSTSDKFwUpgradeProgressViewController(progressLabel: mUploadProgressLabel,
                                                     statusLabel: mUploadStatusProgress,
                                                     progressView: mUploadProgressView)
        mProgresViewController.mFwUploadDelegate=self;
        mDownloadProgressViewController =
            BlueSTSDKDownloadFileViewController(progressLabel: mUploadProgressLabel,
                                                 statusLabel: mUploadStatusProgress,
                                                 progressView: mUploadProgressView)
        self.hideKeyboardWhenTappedAround()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.mFwUpgradeConsole = BlueSTSDKFwUpgradeConsoleSTM32WBA(node: self.node)

        mAddressText.text = String(format:"%X",0x07C000)
        
        mFwTypeSelector.selectedFwType = .applicationFirmware
        //avoid the system to go idle, since we are using the ble to send the data
        //when the system go in idle the ble transfers are suspended
        UIApplication.shared.isIdleTimerDisabled=true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled=false
    }
    
    @IBAction func segmentControlClick(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                mAddressText.text = String(format:"%X",0x07C000)
                break
            case 1:
                mAddressText.text = String(format:"%X",0x0F6000)
                break
            default:
                break
        }
    }
    
    @IBAction func forceItSwitch(_ sender: UISwitch) {
        mNumSectorText.isEnabled = sender.isOn
    }
    
    @IBAction func onSelectButtonFilePressed(_ sender: UIButton) {
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = self
        //docPicker.popoverPresentationController?.barButtonItem=sender
        present(docPicker, animated: true, completion: nil)
    }
    
    private func getFwAddress() -> UInt32?{
        let addressStr = mAddressText.text
        let address = UInt32((addressStr ?? "0"), radix: 16)

        if address != nil && address != 0 {
                return address!
        }

        return nil

    }
    
    @IBAction func startFwUpgrade(_ sender: UIButton) {
        let address = getFwAddress()
        if address != nil && self.mNumSectorText.text != nil && UInt8(self.mNumSectorText.text!) != nil {
            let nbSectors = UInt8(self.mNumSectorText.text!)!
            DispatchQueue.main.async{
                self.mUploadView.isHidden=false
                self.mUploadStatusProgress.text = STM32WBAOtaViewController.FORMATTING_MSG
                let fwType = self.mFwTypeSelector.selectedFwType
                DispatchQueue.global(qos: .background).async {
                    _ = self.mFwUpgradeConsole?.loadFwFile(type:fwType,
                                                           file:self.firmware!,
                                                           delegate: self.mProgresViewController,
                                                           address: address!,
                                                           nbSectorsToErase: nbSectors,
                                                           controller: self)
                }
            }
        }
    }
    
    func error03() {
        DispatchQueue.main.async {
            self.mUploadStatusProgress!.text = "Error File Upload Indication 0x03"
        }
    }
}


extension STM32WBAOtaViewController :UIDocumentPickerDelegate{
   public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
       let url = urls.first
       if(url != nil) {
           self.selectedDocument.text = url!.lastPathComponent
           mNumSectorText.text = calculateNbSectors(url: url!)
           firmware = url
           mStartUploadButton.isEnabled = true;
       }
   }
   
   /*public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){
       startFwUpgrade(firmware: url)
   }*/
    
    private func calculateNbSectors(url: URL) -> String {
        
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            let nbBytesFile = resources.fileSize!
            let sectors = Double(nbBytesFile)/8192.0
            let floorSectors = nbBytesFile/8192
            if(sectors == Double(floorSectors)) {
                return String(floorSectors)
            }
            return String(floorSectors + 1)
        } catch {
            return "-1"
        }
    }
   
}


extension STM32WBAOtaViewController : BlueSTSDKFwUpgradeConsoleCallback{
   
   private static let UPLOAD_COMPLETE_TITLE:String = {
       let bundle = Bundle(for: STM32WBAOtaViewController.self);
       return NSLocalizedString("Upgrade completed", tableName: nil,
                                bundle: bundle,
                                value: "Upgrade completed",
                                comment: "Upgrade completed");
   }();
   
   private static let UPLOAD_COMPLETE_CONTENT:String = {
       let bundle = Bundle(for: STM32WBAOtaViewController.self);
       return NSLocalizedString("The board is resetting", tableName: nil,
                                bundle: bundle,
                                value: "The board is resetting",
                                comment: "The board is resetting");
   }();
   
   public func onLoadComplite(file: URL) {
       DispatchQueue.main.async {
           self.showAllert(title: STM32WBAOtaViewController.UPLOAD_COMPLETE_TITLE,
                           message: STM32WBAOtaViewController.UPLOAD_COMPLETE_CONTENT,
                           closeController: true)
       }
   }
   
   public func onLoadError(file: URL, error: BlueSTSDKFwUpgradeError) {
       
   }
   
   public func onLoadProgres(file: URL, remainingBytes: UInt) {
       
   }
   
}

fileprivate extension UISegmentedControl{
   
   var selectedFwType:BlueSTSDKFwUpgradeType{
       get{
           return self.selectedSegmentIndex == 0 ? .applicationFirmware : .radioFirmware
       }
       set( newValue){
           switch newValue {
               case .applicationFirmware:
                   self.selectedSegmentIndex = 0
               case .radioFirmware:
                   self.selectedSegmentIndex = 1
           }
       }
   }
   
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
