 /*
  * Copyright (c) 2017  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  *   and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  *   conditions and the following disclaimer in the documentation and/or other materials provided
  *   with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  *   STMicroelectronics company nor the names of its contributors may be used to endorse or
  *   promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  *   in a directory whose title begins with st_images may only be used for internal purposes and
  *   shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  *   icons, pictures, logos and other images that are provided with the source code in a directory
  *   whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */
//

import Foundation
import BlueSTSDK
import MBProgressHUD
import BlueSTSDK_Gui
import CoreNFC
import SwiftUI
import UniformTypeIdentifiers
 
 public protocol BlueSTSDKNodeListViewControllerDelegate{
 
 /**
  *  Filter to use for decide if we have to display the node.
  *
  *  @param node node to filter.
  *
  *  @return true for display the node, false otherwise.
  */
  func display(node:BlueSTSDKNode)->Bool
     
  /// Call when the user select a node, but before start the connection procedure
  ///
  /// - Parameter node: node that theu se select
  /// - Note: default implementation is an empty function
  func prepareToConnect(node : BlueSTSDKNode)
 
 /// Call when this viewController is loaded
 ///
 /// - Parameter vc: this UIViewController
 /// - Note: default implementation is an empty function
  func viewIsLoaded(vc: UIViewController) 
    
  /// Call after the node complete the connection
  ///
  /// - Parameter node: node that the user selected and it is now connected
  /// - Note: its default implementation is an empty function
  @available(*, deprecated, message: "use onConnected(node:BlueSTSDKNode, currentViewController:UIViewController)")
  func onConnected(node:BlueSTSDKNode)
  
   /// Call after the node complete the connection
   ///
   /// - Parameter node: node that the user selected and it is now connected
   /// - Parameter curentViewController: current view controller, can be used to change vc
   /// - Note: its default implementation is an empty function
  func onConnected(node:BlueSTSDKNode, currentViewController:UIViewController)
    
    
  /// Tell if you want to move to the demoViewController after the connection
  /// default value = true
  var moveToDemoViewController:Bool {get}
    
  /// Get the view controller to display inside the DemoViewController after the node connects
  ///
  /// - Parameters:
  ///   - node: node selected by the user and in connected state
  ///   - menuManager: delegate to use to add items from the top right menu
  /// - Returns: viewController to display inside the DemoViewController
  /// - Note: this method is called only if moveToDemoViewController is set to true
  /// - Note: its default implementation return nil
  func demoViewController( with node: BlueSTSDKNode, menuManager:BlueSTSDKViewControllerMenuDelegate)->UIViewController?
    

  /// list of advevertise filter to use during the discovery,
  /// default value = BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER
  var advertiseFilters:[BlueSTSDKAdvertiseFilter] {get}

 }
 
 public extension BlueSTSDKNodeListViewControllerDelegate{
    var advertiseFilters:[BlueSTSDKAdvertiseFilter] {
        get {
            return BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER;
        }
    }
    
    var moveToDemoViewController:Bool {
        get {
            return true
        }
    }
    
    func demoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController? {
        return nil
    }
    
    func onConnected(node: BlueSTSDKNode){}
    func onConnected(node: BlueSTSDKNode, currentViewController:UIViewController){
        onConnected(node: node)
    }
    func prepareToConnect(node : BlueSTSDKNode){}
    func viewIsLoaded(vc : UIViewController){}
 }
 
 public class BlueSTSDKNodeListViewCell : UITableViewCell{
    
    @IBOutlet weak var boardName: UILabel!
    @IBOutlet weak var boardDetails: UILabel!
    @IBOutlet weak var boardIsSleepingImage: UIImageView!
    @IBOutlet weak var boardHasExtensionImage: UIImageView!
    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var nodeRunningLabel1: UILabel!
    @IBOutlet weak var nodeRunningLabel2: UILabel!
    @IBOutlet weak var nodeRunningLabel3: UILabel!
    
    @IBOutlet weak var nodeRunningIcon1: UIImageView!
    @IBOutlet weak var nodeRunningIcon2: UIImageView!
    @IBOutlet weak var nodeRunningIcon3: UIImageView!
    @IBOutlet weak var nodeRunningIcon4: UIImageView!
     
    @IBOutlet weak var customModelLabel: UILabel!
 }
 
public class BlueSTSDKNodeListViewController : UITableViewController{
    
    public static func buildWith(delegate: BlueSTSDKNodeListViewControllerDelegate, mac: String) -> UIViewController{
        let bundle = BlueSTSDK_Gui.bundle()
        let storyboard = UIStoryboard(name: "BlueSTSDKMainView", bundle: BlueSTSDK_Gui.bundle())
        let vc = storyboard.instantiateViewController(withIdentifier: "NodeListViewController") as? BlueSTSDKNodeListViewController
        vc?.delegate = delegate
        vc?.boardMac = mac
        return vc!
    }
    
    public static func buildWithNFC(delegate: BlueSTSDKNodeListViewControllerDelegate, mac: String) -> UIViewController{
        let bundle = BlueSTSDK_Gui.bundle()
        let storyboard = UIStoryboard(name: "BlueSTSDKMainView", bundle: BlueSTSDK_Gui.bundle())
        let vc = storyboard.instantiateViewController(withIdentifier: "NodeListViewController") as? BlueSTSDKNodeListViewController
        vc?.delegate = delegate
        vc?.boardMac = mac
        vc?.hasNFCoption = true
        return vc!
    }
    
    private static let SEGUE_DEMO_VIEW = "showDemoView"
    //stop the discovery after 10s
    private static let DISCOVERY_TIMEOUT_MS = 10*1000
    
    private static let CONNECTIONG:String = {
        let bundle = Bundle(for: BlueSTSDKNodeListViewController.self);
        return NSLocalizedString("Connecting", tableName: nil,
                                 bundle: bundle,
                                 value: "Connecting",
                                 comment: "Connecting");
    }();

    /**
     *  local DB firmwares
     */
    private var catalogFw = CatalogService().currentCatalog()
    
    /**
     *  class used for start/stop the discovery process
     */
    private var mManager:BlueSTSDKManager!
    /**
     *  list of discovered nodes
     */
    fileprivate var mNodes:[BlueSTSDKNode] = []

    /**
     *  view to show while the iphone is connecting to the node
     */
    private var networkCheckConnHud:MBProgressHUD? = nil

    private var mConnectedNode:BlueSTSDKNode?=nil
  
    public var delegate:BlueSTSDKNodeListViewControllerDelegate!
    
    var boardMac: String? = nil
    
    public let uiRefreshControl = UIRefreshControl()
    
    private let mMaxIconCode = 55
    private let mBlueSTSDKv2Icons: [UIImage?] = [
        /** 0  -> Low Battery */
        BlueSTSDK_Gui.bundleImage(named: "battery_0"),
        /** 1  -> Battery ok */
        BlueSTSDK_Gui.bundleImage(named: "battery_60"),
        /** 2  -> Battery Full */
        BlueSTSDK_Gui.bundleImage(named: "battery_100"),
        /** 3  -> Battery Charging */
        BlueSTSDK_Gui.bundleImage(named: "battery_80c"),
        /** 4  -> Message */
        BlueSTSDK_Gui.bundleImage(named: "ic_message_24"),
        /** 5  -> Warning/Alarm */
        BlueSTSDK_Gui.bundleImage(named: "ic_warning_24"),
        /** 6  -> Error */
        BlueSTSDK_Gui.bundleImage(named: "ic_error_24"),
        /** 7  -> Ready */
        BlueSTSDK_Gui.bundleImage(named: "ic_ready_outline_24"),
        /** 8  -> Waiting Pairing */
        BlueSTSDK_Gui.bundleImage(named: "ic_bluetooth_waiting_24"),
        /** 9  -> Paired */
        BlueSTSDK_Gui.bundleImage(named: "ic_bluetooth_connected_24"),
        /** 10 -> Log On going */
        BlueSTSDK_Gui.bundleImage(named: "ic_log_on_going_24"),
        /** 11 -> Memory Full */
        BlueSTSDK_Gui.bundleImage(named: "ic_disc_full_24"),
        /** 12 -> Connected to Cloud */
        BlueSTSDK_Gui.bundleImage(named: "ic_cloud_done_24"),
        /** 13 -> Connecting to Cloud */
        BlueSTSDK_Gui.bundleImage(named: "ic_cloud_upload_24"),
        /** 14 -> Cloud not Connected */
        BlueSTSDK_Gui.bundleImage(named: "ic_cloud_off_24"),
        /** 15 -> GPS found */
        BlueSTSDK_Gui.bundleImage(named: "ic_gps_fixed_24"),
        /** 16 -> GPS not Found */
        BlueSTSDK_Gui.bundleImage(named: "ic_gps_not_fixed_24"),
        /** 17 -> GPS Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_gps_off_24"),
        /** 18 -> Led On */
        BlueSTSDK_Gui.bundleImage(named: "ic_flash_on_24"),
        /** 19 -> Led Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_flash_off_24"),
        /** 20 -> Link On */
        BlueSTSDK_Gui.bundleImage(named: "ic_link_on_24"),
        /** 21 -> Link Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_link_off_24"),
        /** 22 -> Wi-Fi On */
        BlueSTSDK_Gui.bundleImage(named: "ic_wifi_on_24"),
        /** 23 -> Wi-Fi Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_wifi_off_24"),
        /** 24 -> Wi-Fi Tethering */
        BlueSTSDK_Gui.bundleImage(named: "ic_wifi_tethering_24"),
        /** 25 -> Low Power */
        BlueSTSDK_Gui.bundleImage(named: "ic_battery_saver_24dp"),
        /** 26 -> Sleeping */
        BlueSTSDK_Gui.bundleImage(named: "ic_sleep_hotel_24"),
        /** 27 -> High Power */
        BlueSTSDK_Gui.bundleImage(named: "ic_battery_charging_full_24"),
        /** 28 -> Microphone On */
        BlueSTSDK_Gui.bundleImage(named: "ic_mic_on_24"),
        /** 29 -> Microphone Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_mic_off_24"),
        /** 30 -> Play */
        BlueSTSDK_Gui.bundleImage(named: "ic_play_arrow_24"),
        /** 31 -> Pause */
        BlueSTSDK_Gui.bundleImage(named: "ic_pause_24"),
        /** 32 -> Stop */
        BlueSTSDK_Gui.bundleImage(named: "ic_stop_24"),
        /** 33 -> Sync On */
        BlueSTSDK_Gui.bundleImage(named: "ic_sync_on_24"),
        /** 34 -> Sync Off */
        BlueSTSDK_Gui.bundleImage(named: "ic_sync_off_24"),
        /** 35 -> Sync Error */
        BlueSTSDK_Gui.bundleImage(named: "ic_sync_error_24"),
        /** 36 -> Lock */
        BlueSTSDK_Gui.bundleImage(named: "ic_lock_24"),
        /** 37 -> Not Lock */
        BlueSTSDK_Gui.bundleImage(named: "ic_lock_open_24"),
        /** 38 -> Star */
        BlueSTSDK_Gui.bundleImage(named: "ic_star_24"),
        /** 39 -> Very dissatisfied */
        BlueSTSDK_Gui.bundleImage(named: "ic_very_dissatisfied_24"),
        /** 40 -> Dissatisfied */
        BlueSTSDK_Gui.bundleImage(named: "ic_dissatisfied_24"),
        /** 41 -> Satisfied */
        BlueSTSDK_Gui.bundleImage(named: "ic_satisfied_24"),
        /** 42 -> Very satisfied */
        BlueSTSDK_Gui.bundleImage(named: "ic_very_satisfied_24"),
        /** 43 -> Sick */
        BlueSTSDK_Gui.bundleImage(named: "ic_sick_24"),
        /** 44 -> Share */
        BlueSTSDK_Gui.bundleImage(named: "ic_share_24"),
        /** 45 -> Filter 1 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_1"),
        /** 46 -> Filter 2 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_2"),
        /** 47 -> Filter 3 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_3"),
        /** 48 -> Filter 4 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_4"),
        /** 49 -> Filter 5 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_5"),
        /** 50 -> Filter 6 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_6"),
        /** 51 -> Filter 7 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_7"),
        /** 52 -> Filter 8 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_8"),
        /** 53 -> Filter 9 */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_9"),
        /** 54 -> Filter 9+ */
        BlueSTSDK_Gui.bundleImage(named: "ic_filter_9plus"),
        /** 55 (mMaxIconCode) -> Icon Code not Recognized  */
        BlueSTSDK_Gui.bundleImage(named: "ic_help_24")
    ]
    
    let cutomEntryChoices: [Int:String] = [0: "Add Custom Fw DB Entry", 1: "Add Custom DTDL Entry", 2: "Reset Fw DB"]
    var customEntrySelected: Int = 0
    
    var hasNFCoption = false
    private var readerSession: NFCReaderSession?
    private static let NFC_READ_MESSAGE = "You can scan NFC-tags by holding them behind the top of your iPhone."
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mManager = BlueSTSDKManager.sharedInstance
        
        /** Pull to Refresh  */
        uiRefreshControl.attributedTitle = NSAttributedString(string: "Refreshing BLE Devices List")
        uiRefreshControl.addTarget(self, action: #selector(manageDiscoveryButton), for: .valueChanged)
        tableView.addSubview(uiRefreshControl)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mNodes.removeAll()
        mManager.nodes.forEach{ node in
            if(node.isConnected()){
                node.disconnect()
            }//if
        }//for each
        mManager.resetDiscovery()
        self.tableView.reloadData()
    }
  
    
    
    /**
     *  Call local DB and retrieve BlueSTSDK v2 firmwares,
     *  start the discovery process,  when the view is shown,
     *  we close the connection with all the previous discovered nodes
     */
    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        delegate.viewIsLoaded(vc: self)
        
        mManager.addDelegate(self)
        //if some node are already discovered show it, and we disconnect
        mManager.discoveryStart(BlueSTSDKNodeListViewController.DISCOVERY_TIMEOUT_MS,
                                advertiseFilters: delegate.advertiseFilters)
        #if targetEnvironment(simulator)
            mManager.addVirtualNode()
        #endif
        
        setNavigationDiscoveryButton();
    }
    
    /**
     *  when the view change we stop the discovering process
     *
     *  @param animated <#animated description#>
     */
    public override func viewWillDisappear(_ animated: Bool) {
        mManager.removeDelegate(self)
        mManager.discoveryStop()
        super.viewWillDisappear(animated)
    }
    
    /**
     *  function called each time the user click in the uibarbutton,
     * it change the status of the discovery
     */
    @objc public func manageDiscoveryButton(){
        if(mManager.isDiscovering){
            mManager.discoveryStop()
            uiRefreshControl.endRefreshing()
        }else{
            mManager.resetDiscovery()
            mNodes.removeAll()
            mNodes.append(contentsOf: mManager.nodes)
            tableView.reloadData()
            uiRefreshControl.beginRefreshing()
            mManager.discoveryStart(BlueSTSDKNodeListViewController.DISCOVERY_TIMEOUT_MS,
                                    advertiseFilters: delegate.advertiseFilters)
        }
    }
    
    /**
     * function the first time to set refreshControl status
     */
    private func setInitialRefreshingControlStatus() {
        if(mManager.isDiscovering){
            uiRefreshControl.beginRefreshing()
        } else {
            uiRefreshControl.endRefreshing()
        }
    }
    
    /**
     *  add the view a bar button for enable/disable the discovery the button will
     * have a search icon if the manager is NOT searching for new nodes, or an X othewise
     */
    private func setNavigationDiscoveryButton() {

        let appName = Bundle.main.displayName
        
        setInitialRefreshingControlStatus()
        
        let icon: UIBarButtonItem.SystemItem = mManager.isDiscovering ? .stop : .search
        let discoveryButton = UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(manageDiscoveryButton))
        
        if (appName == "ST Asset Tracking") {
            if(hasNFCoption){
                let nfcImage = BlueSTSDK_Gui.bundleImage(named: "ic_nfc")
                let nfcButton = UIBarButtonItem(image: nfcImage,  style: .plain, target: self, action: #selector(didTapNfcButton(sender:)))
                self.navigationItem.rightBarButtonItems = [discoveryButton, nfcButton]
            } else {
                self.navigationItem.rightBarButtonItems = [discoveryButton]
            }
        } else {
            let plusImage = BlueSTSDK_Gui.bundleImage(named: "ic_add")
            let addCustomJsonButton = UIBarButtonItem(image: plusImage,  style: .plain, target: self, action: #selector(didTapAddJsonButton(sender:)))
            self.navigationItem.rightBarButtonItems = [discoveryButton, addCustomJsonButton]
        }
    }
     
     @objc func didTapAddJsonButton(sender: AnyObject){
         showCustomEntryChoice()
     }
    
    @objc
    func didTapNfcButton(sender: AnyObject) {
        DispatchQueue.main.async {
            self.startNFCReading()
        }
    }
    
    public func showCustomEntryChoice(){
        var actions: [UIAlertAction] = []
        
        for i in 0...(cutomEntryChoices.count) - 1 {
            actions.append(UIAlertAction.genericButton(cutomEntryChoices[i] ?? " ") { [weak self] _ in
                self?.customEntrySelected = self?.cutomEntryChoices.findCustomEntryKey(forValue: self?.cutomEntryChoices[i] ?? " ") ?? 0
                if(self?.customEntrySelected == 0 || self?.customEntrySelected == 1){
                    /// Add Custom Fw DB Entry - Custom DTDL Entry
                    if #available(iOS 14.0, *) {
                        let types = UTType.types(tag: "json", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
                        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
                        docPicker.delegate = self
                        self?.present(docPicker, animated: true, completion: nil)
                    }else{
                        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                        docPicker.delegate = self
                        self?.present(docPicker, animated: true, completion: nil)
                    }
                } else if(self?.customEntrySelected == 2) {
                    /// Remove Custom Fw DB Entry
                    let catalogService = CatalogService()
                    var catalog = catalogService.currentCatalog()
                    var indexes: [Int]? = []
                    for index in 0...(catalog?.blueStSdkV2.count ?? 1) - 1 {
                        if(catalog?.blueStSdkV2[index].bleVersionIdHex == "0xFF"){
                            indexes?.append(index)
                        }
                    }
                    if !(indexes?.count == 0){
                        catalog?.blueStSdkV2.remove(elementsAtIndices: indexes!)
                        catalogService.storeCatalog(catalog, type: .custom)
                    }
                    self?.showToast(message: "Local Firmware DB restored", seconds: 2.0)
                    self?.tableView.reloadData()
                }
            })
        }
        
        actions.append(UIAlertAction.cancelButton())
        
        UIAlertController.presentActionSheet(from: self, title: "Custom Entry".localizedFromGUI, message: nil, actions: actions)
        
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNodes.count
    }
    
    
    private static let CELL_NAME = "BlueSTSDKNetworkTableViewCell"
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: BlueSTSDKNodeListViewController.CELL_NAME) as! BlueSTSDKNodeListViewCell
        
        let node = mNodes[indexPath.row]
        
        /**If we detect board information via NFC**/
        if(node.address?.lowercased()==self.boardMac?.lowercased()){
            node.addStatusDelegate(self)
            self.showConncetionProgress(node: node)
        }
        
        /**Reset TableView cell**/
        cellView.nodeRunningLabel1.isHidden = true
        cellView.nodeRunningLabel2.isHidden = true
        cellView.nodeRunningLabel3.isHidden = true
        
        cellView.customModelLabel.isHidden = true
        
        cellView.nodeRunningIcon1.isHidden = true
        cellView.nodeRunningIcon2.isHidden = true
        cellView.nodeRunningIcon3.isHidden = true
        cellView.nodeRunningIcon4.isHidden = true
        
        cellView.nodeRunningLabel1.text = " "
        cellView.nodeRunningLabel2.text = " "
        cellView.nodeRunningLabel3.text = " "
        
        cellView.nodeRunningIcon1.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView.nodeRunningIcon2.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView.nodeRunningIcon3.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView.nodeRunningIcon4.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        
        /** Add the first node base informations */
        node.advertiseInfo
        cellView.boardName.text = node.name
        cellView.boardDetails.text = node.addressEx()
        cellView.boardIsSleepingImage.isHidden = !node.isSleeping
        cellView.boardHasExtensionImage.isHidden = !node.hasExtension
        cellView.boardImage.image = node.getTypeImage()
        
        
        guard node.protocolVersion == 0x02 else { return cellView }
        
        /**0. Setup Layout*/
        cellView.nodeRunningLabel1.isHidden = false
        cellView.nodeRunningLabel2.isHidden = false
        cellView.nodeRunningLabel3.isHidden = false
        
        /**1. Retrieve Option Bytes*/
        let optBytesUnsigned = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
        
        /**1. Retrieve Firmware Id*/
        var offsetForFirstOptByte: Int = 0
        var bleFwId: Int = 0
        if(optBytesUnsigned[0]==0x00){
            bleFwId = Int(optBytesUnsigned[1]) + 256
            offsetForFirstOptByte = 1
        }else if(optBytesUnsigned[0]==0xFF){
            bleFwId = 255
        }else{
            bleFwId = Int(optBytesUnsigned[0])
        }
        
        catalogFw = CatalogService().currentCatalog()
        guard let catalogFw = catalogFw else { return cellView }
        guard !(catalogFw.blueStSdkV2==nil) else { return cellView}
        
        for fw in catalogFw.blueStSdkV2 {
            if(node.typeId == __uint8_t(fw.deviceId.dropFirst(2), radix: 16) &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! == bleFwId) {
                
                if(bleFwId==255){
                    cellView.customModelLabel.isHidden = false
                }
                /**3. Set Board Name & Firmware ID info*/
                cellView.nodeRunningLabel1.text = "[" + fw.boardName + " Fw: " + fw.name + " v:" + fw.version + "]"

                /**4. Scan Option Bytes and Fill correctly*/
                guard let dbFwOpt = fw.optionBytes else { return cellView }
                
                for var i in (0..<dbFwOpt.count){
                    
                    var currentOptByte = dbFwOpt[i]
                    var stringToDisplay: String = ""
                    
                    if(currentOptByte.format == "int"){
                        /** Check Escape Message */
                        if (currentOptByte.escapeValue != nil){
                            if(currentOptByte.escapeValue! == optBytesUnsigned[i + 1 + offsetForFirstOptByte]){
                                stringToDisplay = currentOptByte.escapeMessage ?? " "
                            } else {
                                stringToDisplay = currentOptByte.name + " " + String((Int(optBytesUnsigned[i+1+offsetForFirstOptByte]) - currentOptByte.negativeOffset!) * currentOptByte.scaleFactor!) + " " + currentOptByte.type!
                            }
                        } else if(currentOptByte.negativeOffset != nil && currentOptByte.scaleFactor != nil && currentOptByte.type != nil){
                            stringToDisplay = currentOptByte.name + " " + String((Int(optBytesUnsigned[i+1+offsetForFirstOptByte]) - currentOptByte.negativeOffset!) * currentOptByte.scaleFactor!) + " " + currentOptByte.type!
                        }
                        
                        cellView.nodeRunningLabel2.text = stringToDisplay
                        
                    } else if(currentOptByte.format == "enum_string"){
                        let optByteStringValues = currentOptByte.stringValues
                        guard optByteStringValues != nil else { return cellView }
                        
                        var found: String?
                        
                        for var element in optByteStringValues! {
                            if(element.value == optBytesUnsigned[i+1+offsetForFirstOptByte]){
                                found = element.displayName
                            }
                        }
                        
                        if(found != nil){
                            stringToDisplay = currentOptByte.name + " " + found!
                        }else{
                            stringToDisplay = currentOptByte.name
                        }
                        
                        if(cellView.nodeRunningLabel3.text == nil || cellView.nodeRunningLabel3.text == " "){
                            cellView.nodeRunningLabel3.text = stringToDisplay
                        } else {
                            cellView.nodeRunningLabel3.text = String((cellView.nodeRunningLabel3.text!.description) + " " + stringToDisplay)
                        }
                        
                    } else if(currentOptByte.format == "enum_icon"){
                        
                        let optByteIconValues = currentOptByte.iconValues
                        guard optByteIconValues != nil else { return cellView }
                        
                        var found: Int? = nil
                        
                        for var element in optByteIconValues! {
                            if(element.value == optBytesUnsigned[i+1+offsetForFirstOptByte]){
                                found = element.code
                            }
                        }
                        
                        guard let found = found else { return cellView }
                        guard found < 46 else { return cellView }
                        
                        if(cellView.nodeRunningIcon1.isHidden == true){
                            cellView.nodeRunningIcon1.isHidden = false
                            cellView.nodeRunningIcon1.image = mBlueSTSDKv2Icons[found]
                        }else if(cellView.nodeRunningIcon2.isHidden == true){
                            cellView.nodeRunningIcon2.isHidden = false
                            cellView.nodeRunningIcon2.image = mBlueSTSDKv2Icons[found]
                        }else if(cellView.nodeRunningIcon3.isHidden == true){
                            cellView.nodeRunningIcon3.isHidden = false
                            cellView.nodeRunningIcon3.image = mBlueSTSDKv2Icons[found]
                        }else if(cellView.nodeRunningIcon4.isHidden == true){
                            cellView.nodeRunningIcon4.isHidden = false
                            cellView.nodeRunningIcon4.image = mBlueSTSDKv2Icons[found]
                        }
                        
                    }
                    i=i+1
                }//for
            }
        }
        return cellView
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///TODO: dtmi download
        let node = mNodes[indexPath.row]
        node.addStatusDelegate(self)
        showConncetionProgress(node: node)
    }
  
    /**
     *  display the activity indicator view while we wait that the connection is done
     *
     *  @param node node selecte by the user
     */
    
    private func showConncetionProgress(node:BlueSTSDKNode){
        guard !node.isConnected() else{
            return
        }
        
        networkCheckConnHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        networkCheckConnHud?.mode = .indeterminate
        networkCheckConnHud?.removeFromSuperViewOnHide = true
        networkCheckConnHud?.label.text = BlueSTSDKNodeListViewController.CONNECTIONG
        networkCheckConnHud?.show(animated: true)
        
        delegate.prepareToConnect(node: node)
        node.connect()
    }
    
    /**
     *  pass the deleage to the next view controler
     *
     *  @param segue  storyboard segue
     *  @param sender view that start the change
     */
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == BlueSTSDKNodeListViewController.SEGUE_DEMO_VIEW,
            let node = sender as? BlueSTSDKNode,
            let demoView = segue.destination as? BlueSTSDKDemoViewController,
            let demoController = delegate.demoViewController(with: node, menuManager: demoView){
                demoView.demoViewController=demoController;
                demoView.node=node;
        }//if
    }

    
 }
 
 extension BlueSTSDKNodeListViewController : BlueSTSDKManagerDelegate{
    
    public func manager(_ manager: BlueSTSDKManager, didDiscoverNode node: BlueSTSDKNode) {
        if(self.delegate.display(node: node)){
            DispatchQueue.main.async {
                self.mNodes.append(node)
                self.tableView.reloadData()
            }//async
        }//if display
    }
    
    public func manager(_ manager: BlueSTSDKManager, didChangeDiscovery enable: Bool) {
        DispatchQueue.main.async {
            self.setNavigationDiscoveryButton()
        }
    }
 }
 
 extension BlueSTSDKNodeListViewController : BlueSTSDKNodeStateDelegate{
    private static let ERROR_MSG_TIMEOUT = 3.0
    private static let ERROR_MSG_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKNodeListViewController.self);
        return NSLocalizedString("Cannot connect with the device: %@", tableName: nil,
                                 bundle: bundle,
                                 value: "Cannot connect with the device: %@",
                                 comment: "Cannot connect with the device: %@");
    }();
    
    public func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        if(newState == .connected){
            DispatchQueue.main.async {
                self.onNodeConnected(node)
            }
        }else if (newState == .dead || newState == .unreachable){
            DispatchQueue.main.async {
                self.onNodeError(node)
            }
        }// if-else
    }// didChange
    
    private func onNodeConnected(_ node:BlueSTSDKNode){
        networkCheckConnHud?.hide(animated: true)
        networkCheckConnHud=nil
        delegate.onConnected(node: node,currentViewController:self)
        if delegate.moveToDemoViewController {
            performSegue(withIdentifier: BlueSTSDKNodeListViewController.SEGUE_DEMO_VIEW, sender: node)
        }
    }
    
     private func onNodeError(_ node:BlueSTSDKNode){
         let str = String(format: BlueSTSDKNodeListViewController.ERROR_MSG_FORMAT, node.name)
         networkCheckConnHud?.hide(animated: true)
         networkCheckConnHud=nil
         networkCheckConnHud = MBProgressHUD.showAdded(to: self.view, animated: true)
         networkCheckConnHud?.label.text = str;
         networkCheckConnHud?.show(animated: true)
         networkCheckConnHud?.hide(animated: true, afterDelay: BlueSTSDKNodeListViewController.ERROR_MSG_TIMEOUT)
     }
}

@available(iOS 13.0, *)
extension BlueSTSDKNodeListViewController: UIDocumentPickerDelegate{
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){}
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
        if(customEntrySelected==0){
            addCustomFw(urls: urls)
        } else {
            addCustomDTDL(urls: urls)
        }
    }
    
    private func addCustomFw(urls: [URL]){
        if let selectedFile = urls.first{
            do{
                let fileHandler = try FileHandle(forReadingFrom: selectedFile)
                let data = fileHandler.readDataToEndOfFile()
                try fileHandler.close()
                do {
                    
                    let decoder = JSONDecoder()
                    
                    do {
                        let jsonFw = try? decoder.decode(CustomJSON.self, from: data)
                        if !(jsonFw?.bluestsdk_v2 == nil){
                            for fw in jsonFw!.bluestsdk_v2! {
                                /** ADD only Custom Firmware*/
                                if(fw.bleVersionIdHex == "0xFF"){
                                    appendFwV2(firmwareV2: fw)
                                    showToast(message: "Custom Fw DB Entry added.", seconds: 2.0)
                                    tableView.reloadData()
                                }
                            }
                        }else{
                            showToast(message: "Invalid Custom Fw DB Entry file selected.", seconds: 2.0)
                        }
                    } catch { showToast(message: "Invalid Custom Fw DB Entry file selected.", seconds: 2.0) }
                } catch { showToast(message: "Invalid JSON.", seconds: 2.0) }
            } catch { showToast(message: "Invalid JSON.", seconds: 2.0) }
        }
    }
    
    private func addCustomDTDL(urls: [URL]){
        if let selectedFile = urls.first{
            do{
                let fileHandler = try FileHandle(forReadingFrom: selectedFile)
                let data = fileHandler.readDataToEndOfFile()
                try fileHandler.close()
                do {
                    let decoder = JSONDecoder()
                    do {
                        
                        let jsonDTDL = try? decoder.decode(PnPLikeDtmiCommands.self, from: data)
                        guard let jsonDTDL = jsonDTDL else {
                            showToast(message: "Invalid Custom DTDL file selected.", seconds: 2.0)
                            return
                        }
                        PnPLikeService().storePnPLDtmi(jsonDTDL, type: .custom)
                        showToast(message: "Custom DTDL Entry added.", seconds: 2.0)
                        
                    } catch { showToast(message: "Invalid Custom DTDL file selected.", seconds: 2.0) }
                } catch { showToast(message: "A problem occurred.", seconds: 2.0) }
            } catch { showToast(message: "A problem occurred.", seconds: 2.0) }
        }
    }
    
    private func appendFwV2(firmwareV2: Firmware) {
        let catalogService = CatalogService()
        
        var catalog = catalogService.currentCatalog()
        for index in 0...(catalog?.blueStSdkV2.count ?? 1) - 1 {
            if(catalog?.blueStSdkV2[index].bleVersionIdHex == "0xFF" && catalog?.blueStSdkV2[index].deviceId == firmwareV2.deviceId ){
                catalog?.blueStSdkV2.remove(at: index)
            }
        }
        
        catalog?.blueStSdkV2.append(firmwareV2)
        catalogService.storeCatalog(catalog, type: .custom)
        
        showToast(message: "Custom Fw Db Entry added.", seconds: 2.0)
        self.tableView.reloadData()
    }
    
   
}

extension BlueSTSDKNodeListViewController {
    func startNFCReading() {
        startReadNDef()
    }
    
    func onNfcRead(session: NFCReaderSession, result: Result<String,NfcTagIOError>) {
        switch result {
        case .success(let data):
            session.invalidate()
            DispatchQueue.main.async {
                let payloadStr = data.description
                
                if let mac = payloadStr.range(of: "Add=") {
                    let macAdress = payloadStr[mac.upperBound...].prefix(17)
                    self.boardMac = String(macAdress)
                    self.tableView.reloadData()
                }
            }
        case .failure(let error):
            manageFailure(session: session, error: error)
        }
    }
    
    func manageFailure(session: NFCReaderSession, error: NfcTagIOError) {
        DispatchQueue.main.async {
            if #available(iOS 13, *) {
                session.invalidate(errorMessage: error.localizedDescription)
            } else {
                session.invalidate()
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension BlueSTSDKNodeListViewController: NFCNDEFReaderSessionDelegate {
    private func startReadNDef() {
        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = BlueSTSDKNodeListViewController.NFC_READ_MESSAGE
        readerSession?.begin()
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        NSLog("NFC: Error Reading Tag", error.localizedDescription)

        guard let readerError = error as? NFCReaderError else {
            onNfcRead(session: session, result: .failure(.unknown))
            return
        }
        switch readerError.code {
        case .readerSessionInvalidationErrorFirstNDEFTagRead,
             .readerSessionInvalidationErrorUserCanceled:
            break // invalidation is managed by system and is user visibile

        default:
            onNfcRead(session: session, result: .failure(readerError.toSmarTagIOError))
        }
    }
        
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let UriNFCNDEFPayload = findUriPayload(messages: messages)
        
        guard let UriNFCNDEFPayload = UriNFCNDEFPayload else { onNfcRead(session: session, result: .failure(.unknown)); return }
        let payloadData = UriNFCNDEFPayload.payload
        let payloadStr = String(data: payloadData, encoding: .utf8)
        guard let payloadStr = payloadStr else { onNfcRead(session: session, result: .failure(.unknown)); return }
        self.onNfcRead(session: session, result: .success(payloadStr))
    }
    
    private func findUriPayload(messages: [NFCNDEFMessage]) -> NFCNDEFPayload?{
        return  messages.first?.records.first{ rec in
            return rec.typeNameFormat == .nfcWellKnown
        }
    }
}

public enum NfcTagIOError: Error {
    case malformedNDef
    case wrongProtocolVersion
    case lostConnection
    case tagResponseError
    case unknown
}

extension NFCReaderError {
    var toSmarTagIOError : NfcTagIOError {
        switch self.code {
        case .readerTransceiveErrorTagConnectionLost:
            return .lostConnection
        case .readerTransceiveErrorTagResponseError:
            return .tagResponseError
        default:
            return .unknown
        }
    }
}

struct CustomJSON: Codable {
    public let bluestsdk_v2: [Firmware]?

    private enum CodingKeys: String, CodingKey {
        case bluestsdk_v2 = "bluestsdk_v2"
    }
}

extension UIViewController {
    func showToast(message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

/** Used for find key from dictionary value */
extension Dictionary where Value: Equatable {
   func findCustomEntryKey(forValue val: Value) -> Key? {
       return first(where: { $1 == val })?.key
   }
}

extension Array {
    mutating func remove(elementsAtIndices indicesToRemove: [Int]) -> [Element] {
        let removedElements = indicesToRemove.map { self[$0] }
        for indexToRemove in indicesToRemove.sorted(by: >) {
            remove(at: indexToRemove)
        }
        return removedElements
    }
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
            return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
