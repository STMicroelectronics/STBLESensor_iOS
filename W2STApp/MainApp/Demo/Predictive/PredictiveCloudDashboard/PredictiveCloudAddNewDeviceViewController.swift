//
//  PredictiveCloudAddNewDeviceViewController.swift
//  W2STApp

import Foundation
import CoreData

class PredictiveCloudAddNewDeviceViewController: UIViewController {
    
    var container: NSPersistentContainer!
    
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let scrollView = UIScrollView()

    private let deviceNameLabel = UILabel()
    private let deviceNameField = UITextField()
    private let deviceIDLabel = UILabel()
    private let deviceIDField = UITextField()

    private let saveButton = UIButton()
    private var mainStack: UIStackView!
    
    private var deviceName: String
    private var deviceID: String
    private var pmServices: PredictiveMaintenanceCloudServices
    
    public let node: BlueSTSDKNode
    
    private var extFeature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    
    init(node: BlueSTSDKNode, deviceName: String, deviceID: String, pmServices: PredictiveMaintenanceCloudServices) {
        self.node = node
        self.deviceName = deviceName
        self.deviceID = deviceID
        self.pmServices = pmServices
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "PMCloudDeviceCertificate")

        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        title = "Add new device"
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(backToPrevViewController))
        
        loadingView.hidesWhenStopped = true
        view.addSubviewAndCenter(loadingView)
        
        mainStack = UIStackView.getVerticalStackView(withSpacing: 12, views: [
            UIStackView.getVerticalStackView(withSpacing: 2, views: [
                deviceNameLabel, deviceNameField
            ]),
            UIStackView.getVerticalStackView(withSpacing: 2, views: [
                deviceIDLabel, deviceIDField
            ])
        ])
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.addSubview(mainStack, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])

        view.addSubview(saveButton, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            equalDimension(\.heightAnchor, to: 44)
        ])
        
        view.addSubview(scrollView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor, toView: saveButton, withAnchor: \.topAnchor)
        ])
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        [deviceNameField, deviceIDField].forEach { view in
            view.cornerRadius = 12
            view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            view.setDimensionContraints(width: nil, height: 40)
            
            view.leftViewMode = .always
            let spacer = UIView()
            spacer.setDimensionContraints(width: 16, height: nil)
            view.leftView = spacer
        }
        
        [deviceNameLabel, deviceIDLabel].forEach { view in
            view.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        }
        deviceNameLabel.text = "DEVICE NAME".uppercased()
        deviceIDLabel.text = "DEVICE ID".uppercased()
        deviceNameField.text = deviceName
        deviceIDField.text = deviceID
        deviceIDField.isEnabled = false
        
        saveButton.backgroundColor = currentTheme.color.primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("ADD", for: .normal)
        
        saveButton.onTap { [weak self] _ in
            self?.addPMDevice()
        }
        
        deviceNameField.onKeyPress { [weak self] value in
            self?.deviceName = value
            self?.updateUI()
            return true
        }
        
        manageKeyboard()
        updateUI()
    }
    
    @objc
    private func backToPrevViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func addPMDevice() {
        pmServices.addPMDevice(name: deviceName, thingName: deviceID, { [weak self] certificate, privateKey, error in
            if let error = error {
                self?.showErrorAlert(error)
            } else {
                if !(certificate==nil && privateKey==nil){
                    let pmCloudDevice = PMCloudDevice(context: (self?.container.viewContext)!)
                    pmCloudDevice.certificate = certificate
                    pmCloudDevice.key = privateKey
                    pmCloudDevice.id = self?.deviceID
                    pmCloudDevice.type = self?.deviceName
                    
                    self?.saveContext()
                    
                    /** Send Cert To Node */
                    guard let completeCertificate = self?.buildPMCloudDeviceCert(certificate: certificate, deviceId: self?.deviceID, privateKey: privateKey) else { return }
                    self?.extFeature?.sendCommand(.setCert, string: completeCertificate)
                }
                
                self?.backToPrevViewController()
            }
        })
    }
    
    private func buildPMCloudDeviceCert(certificate: String?, deviceId: String?, privateKey: String?) -> String? {
        let param1 : [String: String?] = ["Certificate":certificate]
        let param2 : [String: String?] = ["DeviceId":deviceId]
        let param3 : [String: String?] = ["PrivateKey":privateKey]
        
        var jsonString: String? = nil

        do {
            let data1 = try JSONSerialization.data(withJSONObject: param1, options: JSONSerialization.WritingOptions()) as NSData
            let data2 = try JSONSerialization.data(withJSONObject: param2, options: JSONSerialization.WritingOptions()) as NSData
            let data3 = try JSONSerialization.data(withJSONObject: param3, options: JSONSerialization.WritingOptions()) as NSData
            
            var string1 = NSString(data: data1 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            var string2 = NSString(data: data2 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            var string3 = NSString(data: data3 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            string1.removeFirst()
            string1.removeLast()
            
            string2.removeFirst()
            string2.removeLast()
            
            string3.removeFirst()
            string3.removeLast()
            
            jsonString = "{\(string1),\(string2),\(string3)}"
            
            return jsonString
        } catch _ {
            print ("JSON Failure")
            return nil
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error", message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateUI() {
        saveButton.isEnabled = !(deviceName == "")
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.5
    }
    
    private func manageKeyboard() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            let height = KeyboardUtilities.getKeyboardHeight(notification)
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -height
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -16
        }
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        mainStack.isHidden = visible
        saveButton.isHidden = visible
        navigationItem.leftBarButtonItem?.isEnabled = !visible
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
    }
    
    private func presentErrorAlert(_ message: String) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: message, confirmButton: UIAlertAction.genericButton())
    }
    
    /** SAVE DATA INTO DB Predictive Maintenance Device Certificate [DB Funtions] */
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}
