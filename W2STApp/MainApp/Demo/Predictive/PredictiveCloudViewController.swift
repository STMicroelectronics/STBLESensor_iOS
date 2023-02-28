//
//  PredictiveCloudViewController.swift
//  W2STApp

import Foundation
import Alamofire
import AssetTrackingCloudDashboard

class PredictiveCloudViewController : BlueMSDemoTabViewController, DeviceManagerDelegate{
    
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private var loginManager = CloudConfig.predmntLoginManager
    
    public weak var delegate: DeviceManagerDelegate?
    
    func controller(_ controller: UIViewController, didCompleteDeviceManager deviceManager: DeviceManager) {
        let predmntDeviceListController : PredictiveCloudDeviceListViewController = PredictiveCloudDeviceListViewController(node: self.node)
        
        var viewControllers = controller.navigationController?.viewControllers
        if(viewControllers != nil){
            viewControllers!.remove(at: viewControllers!.count - 1)
            viewControllers!.append(predmntDeviceListController)
            controller.navigationController?.setViewControllers(viewControllers!, animated: true)
        }
    }
    
    private func loadLoginViewController() {
        let cloudVc = AssetTrackingCloudBundle.buildATRLoginViewController(loginManager: CloudConfig.predmntLoginManager)
        cloudVc.delegate = self
        self.present(UINavigationController(rootViewController: cloudVc), animated: true, completion: nil)
    }
    
    /**Start interaction with Predictive Maintenance Dashboard**/
    @IBAction func onClickBtnDashboard(_ sender: UIButton) {
        loadLoginViewController()
    }
    
    /**Start interaction with Arrowhead Catalog*/
    @IBAction func onClickBtnArrowhead(_ sender: UIButton) {
        AF.request(arrowheadGETUrl).responseDecodable(of: ArrowheadResponseTemplate.self) { response in
            switch response.result {
                case .success(let response):
                    let dialogMessage = self.createMessageArrowheadDialog(arrowheadData: response)
                    self.createArrowheadDialog(dialogMessage: dialogMessage, url: response.address)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    private func createMessageArrowheadDialog(arrowheadData: ArrowheadResponseTemplate) -> String{
        return "An occurrence of the ST Predictive Maintenance System was detected in the Arrowhead Catalog. Here are the details:\n\nID: \(arrowheadData.id)\nSystem Name: \(arrowheadData.systemName)\nAddress: \(arrowheadData.address)\nCreated At: \(arrowheadData.createdAt ?? "/")\n Updated At: \(arrowheadData.updatedAt ?? "/")\n\nGo to the detected address and try Predictive Maintenance System"
    }
    
    private func createArrowheadDialog(dialogMessage: String, url: String) {
        let alert = UIAlertController(title: "Arrowhead Project", message: dialogMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go To The Address", style: .default, handler: { action in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
          }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func doLogin(_ completion: @escaping (Error?) -> Void) {
        loginManager.authenticate(from: self) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviewAndCenter(loadingView)
        loadingView.hidesWhenStopped = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
        
}
