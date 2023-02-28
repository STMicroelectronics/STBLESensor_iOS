

import Foundation

class STAzureDashboardConfigViewController : BlueMSCloudConfigDetailsViewController {
    
    @IBOutlet weak var mDeviceNameText: UITextField!
    @IBOutlet weak var mDeviceIdLabel: UILabel!
    @IBOutlet weak var mRegisterDeviceButton: UIButton!
    
    @IBOutlet weak var mRegistrationStatusLabel: UILabel!
    private var mDeviceConnectionParam:STAzureRegisterdDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mDeviceNameText.delegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let deviceId = self.node.addressEx()
        mDeviceIdLabel.text = self.node.addressEx()
        loadDeviceParam(id: deviceId)
    }
    
    private func loadDeviceParam(id:String){
        mDeviceConnectionParam = STAzureRegistredDeviceDB.instance.registerdDeviceDao.getRegisterDevice(id: id)
        if let knowDevice =  mDeviceConnectionParam {
            showRegisteredDevice(knowDevice)
        }else{
            showRegistrationButton()
        }
    }
    
    private func showRegistrationButton(){
        mRegistrationStatusLabel.text = Self.UNKNOW_DEVICE
        mDeviceNameText.text = self.node.friendlyName()
        mRegisterDeviceButton.isHidden = false
    }
    
    private func showRegisteredDevice(_ device:STAzureRegisterdDevice){
        mDeviceNameText.text = device.name
        mRegistrationStatusLabel.text = Self.KNOW_DEVICE
        mRegisterDeviceButton.isHidden = true
    }
    
    override func buildConnectionFactory()->BlueMSCloudIotConnectionFactory?{
        if let knowDevice = mDeviceConnectionParam {
            return STAzureDashboardConnectionFactory(forDevice:knowDevice)
        }else{
            return nil
        }
    }
    
    @IBAction func onRegisterDeviceButtonPressed(_ sender: UIButton) {
        guard let deviceName = mDeviceNameText.text,
            !deviceName.isEmpty else{
                showAllert(title: "Invalid Data", message: "Empty device name")
                return
        }
                
        let deviceId = mDeviceIdLabel.text!
        let vc = STAzureDashboardRegisterBoardViewController.instantiate(deviceId: mDeviceIdLabel.text!, deviceName: deviceName){ [weak self] in
            self?.loadDeviceParam(id: deviceId)
            
        }
        vc.modalPresentationStyle = .popover
        let popOverVc = vc.popoverPresentationController
        popOverVc?.permittedArrowDirections = .any
        popOverVc?.sourceView = sender
                
        present(vc, animated: true, completion: nil)
    }
    
    static let KNOW_DEVICE:String = {
        let bundle = Bundle(for: STAzureDashboardConfigViewController.self)
        return NSLocalizedString("Ready to connect", tableName: nil, bundle: bundle,
                                 value: "Ready to connect", comment: "")
    }();
    
    static let UNKNOW_DEVICE:String = {
        let bundle = Bundle(for: STAzureDashboardConfigViewController.self)
        return NSLocalizedString("Unknow device", tableName: nil, bundle: bundle,
                                 value: "Unknow device", comment: "")
    }();
    
}

extension STAzureDashboardConfigViewController : UITextFieldDelegate{
    //hide keyboard when the user press return
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
