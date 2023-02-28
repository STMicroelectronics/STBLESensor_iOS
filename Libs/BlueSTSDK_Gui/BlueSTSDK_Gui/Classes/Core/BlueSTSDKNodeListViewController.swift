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
import CoreData
import BlueSTSDK_Gui
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
        let bundle = Bundle(for: BlueSTSDKNodeListViewController.self);
        let storyboard = UIStoryboard(name: "BlueSTSDKMainView", bundle: BlueSTSDK_Gui.bundle())
        let vc = storyboard.instantiateViewController(withIdentifier: "NodeListViewController") as? BlueSTSDKNodeListViewController
        vc?.delegate = delegate
        vc?.boardMac = mac
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
    private var localDB: ReadBoardFirmwareDataBase!
    
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
    
    private let mMaxIconCode = 45
    private let mBlueSTSDKv2Icons: [UIImage?] = [
        /** 0  -> Low Battery */
        UIImage(named: "battery_0", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil),
        /** 1  -> Battery ok */
        UIImage(named: "battery_60", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 2  -> Battery Full */
        UIImage(named: "battery_100", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 3  -> Battery Charging */
        UIImage(named: "battery_80c", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 4  -> Message */
        UIImage(named: "ic_message_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 5  -> Warning/Alarm */
        UIImage(named: "ic_warning_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 6  -> Error */
        UIImage(named: "ic_error_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 7  -> Ready */
        UIImage(named: "ic_ready_outline_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 8  -> Waiting Pairing */
        UIImage(named: "ic_bluetooth_waiting_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 9  -> Paired */
        UIImage(named: "ic_bluetooth_connected_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 10 -> Log On going */
        UIImage(named: "ic_log_on_going_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 11 -> Memory Full */
        UIImage(named: "ic_disc_full_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 12 -> Connected to Cloud */
        UIImage(named: "ic_cloud_done_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 13 -> Connecting to Cloud */
        UIImage(named: "ic_cloud_upload_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 14 -> Cloud not Connected */
        UIImage(named: "ic_cloud_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 15 -> GPS found */
        UIImage(named: "ic_gps_fixed_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 16 -> GPS not Found */
        UIImage(named: "ic_gps_not_fixed_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 17 -> GPS Off */
        UIImage(named: "ic_gps_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 18 -> Led On */
        UIImage(named: "ic_flash_on_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 19 -> Led Off */
        UIImage(named: "ic_flash_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 20 -> Link On */
        UIImage(named: "ic_link_on_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 21 -> Link Off */
        UIImage(named: "ic_link_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 22 -> Wi-Fi On */
        UIImage(named: "ic_wifi_on_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 23 -> Wi-Fi Off */
        UIImage(named: "ic_wifi_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 24 -> Wi-Fi Tethering */
        UIImage(named: "ic_wifi_tethering_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 25 -> Low Power */
        UIImage(named: "ic_battery_saver_24dp", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 26 -> Sleeping */
        UIImage(named: "ic_sleep_hotel_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 27 -> High Power */
        UIImage(named: "ic_battery_charging_full_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 28 -> Microphone On */
        UIImage(named: "ic_mic_on_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 29 -> Microphone Off */
        UIImage(named: "ic_mic_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 30 -> Play */
        UIImage(named: "ic_play_arrow_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 31 -> Pause */
        UIImage(named: "ic_pause_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 32 -> Stop */
        UIImage(named: "ic_stop_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 33 -> Sync On */
        UIImage(named: "ic_sync_on_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 34 -> Sync Off */
        UIImage(named: "ic_sync_off_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 35 -> Sync Error */
        UIImage(named: "ic_sync_error_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 36 -> Lock */
        UIImage(named: "ic_lock_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 37 -> Not Lock */
        UIImage(named: "ic_lock_open_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 38 -> Star */
        UIImage(named: "ic_star_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 39 -> Very dissatisfied */
        UIImage(named: "ic_very_dissatisfied_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 40 -> Dissatisfied */
        UIImage(named: "ic_dissatisfied_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 41 -> Satisfied */
        UIImage(named: "ic_satisfied_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 42 -> Very satisfied */
        UIImage(named: "ic_very_satisfied_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 43 -> Sick */
        UIImage(named: "ic_sick_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 44 -> Share */
        UIImage(named: "ic_share_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
        /** 45 (mMaxIconCode) -> Icon Code not Recognized  */
        UIImage(named: "ic_help_24", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none,
    ]
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mManager = BlueSTSDKManager.sharedInstance
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
        
        localDB = ReadBoardFirmwareDataBase()
        
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
        }else{
            mManager.resetDiscovery()
            mNodes.removeAll()
            mNodes.append(contentsOf: mManager.nodes)
            tableView.reloadData()
            mManager.discoveryStart(BlueSTSDKNodeListViewController.DISCOVERY_TIMEOUT_MS,
                                    advertiseFilters: delegate.advertiseFilters)
        }
    }
    
    /**
     *  add the view a bar button for enable/disable the discovery the button will
     * have a search icon if the manager is NOT searching for new nodes, or an X othewise
     */
    private func setNavigationDiscoveryButton() {

        let plusImage = UIImage(named: "ic_add", in: Bundle(for: BlueSTSDKNodeListViewController.self), compatibleWith: nil) ?? .none
        let addCustomJsonButton = UIBarButtonItem(image: plusImage,  style: .plain, target: self, action: #selector(didTapEditButton(sender:)))
        
        let icon:UIBarButtonItem.SystemItem = mManager.isDiscovering ? .stop : .search
        self.navigationItem.rightBarButtonItems =
            [UIBarButtonItem(barButtonSystemItem: icon, target: self, action: #selector(manageDiscoveryButton)), addCustomJsonButton]
    }
     
     @objc func didTapEditButton(sender: AnyObject){
         
         
         if #available(iOS 14.0, *) {
             let types = UTType.types(tag: "json", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
             let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
             docPicker.delegate = self
             present(docPicker, animated: true, completion: nil)
         }else{
             let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
             docPicker.delegate = self
             present(docPicker, animated: true, completion: nil)
         }
         
         
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNodes.count
    }
    
    
    private static let CELL_NAME = "BlueSTSDKNetworkTableViewCell"
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: BlueSTSDKNodeListViewController.CELL_NAME) as? BlueSTSDKNodeListViewCell
        
        let node = mNodes[indexPath.row]
        
        /**If we detect board information via NFC**/
        if(node.address?.lowercased()==self.boardMac?.lowercased()){
            node.addStatusDelegate(self)
            self.showConncetionProgress(node: node)
        }
        
        /**Reset TableView cell**/
        cellView?.nodeRunningLabel1.isHidden = true
        cellView?.nodeRunningLabel2.isHidden = true
        cellView?.nodeRunningLabel3.isHidden = true
        
        cellView?.customModelLabel.isHidden = true
        
        cellView?.nodeRunningIcon1.isHidden = true
        cellView?.nodeRunningIcon2.isHidden = true
        cellView?.nodeRunningIcon3.isHidden = true
        cellView?.nodeRunningIcon4.isHidden = true
        
        cellView?.nodeRunningLabel1.text = " "
        cellView?.nodeRunningLabel2.text = " "
        cellView?.nodeRunningLabel3.text = " "
        
        cellView?.nodeRunningIcon1.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView?.nodeRunningIcon2.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView?.nodeRunningIcon3.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        cellView?.nodeRunningIcon4.image = UIImage(named: "sleepIcon", in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
        
        
        if(node.protocolVersion == 0x02){
            
            /**0. Setup Layout*/
            cellView?.nodeRunningLabel1.isHidden = false
            cellView?.nodeRunningLabel2.isHidden = false
            cellView?.nodeRunningLabel3.isHidden = false
            
            /**1. Retrieve Option Bytes*/
            let optBytes = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
            print("optBytes0 -> \(optBytes[0]) and optBytes1 \(optBytes[1])")
            
            /**1. Retrieve Firmware Id*/
            var bleFwId: Int = 0
            if(optBytes[0]==0x00){
                bleFwId = Int(optBytes[1]) + 256
            }else if(optBytes[0]==0xFF){
                bleFwId = 255
            }else{
                bleFwId = Int(optBytes[0])
            }
            
            localDB.catalogFirmwares?.firmwares.forEach{ c in
                for fw in c.bluestsdk_v2! {
                    if(node.typeId == __uint8_t(fw.ble_dev_id.dropFirst(2), radix: 16) &&  __uint8_t(fw.ble_fw_id.dropFirst(2), radix: 16)! == bleFwId) {
                        
                        if(bleFwId==255){
                            cellView?.customModelLabel.isHidden = false
                        }
                        /**3. Set Board Name & Firmware ID info*/
                        cellView?.nodeRunningLabel1.text = "[" + fw.brd_name + " Fw: " + fw.fw_name + " v:" + fw.fw_version + "]"
                        
                        var dbFwOpt = fw.option_bytes
                        
                        if !(dbFwOpt==nil){
                        /**4. Scan Option Bytes and Fill correctly*/
                            for var i in (0..<dbFwOpt!.count){
                                
                                var currentOptByte = dbFwOpt![i]
                                var stringToDisplay: String = ""
                                
                                if(dbFwOpt![i].format == "int"){
                                    stringToDisplay = currentOptByte.name! + " " + String((Int(optBytes[i+1]) - currentOptByte.negative_offset!) * currentOptByte.scale_factor!) + " " + currentOptByte.type!
                                    cellView?.nodeRunningLabel2.text = stringToDisplay
                                    
                                }else if(dbFwOpt![i].format == "enum_string"){
                                    var found: String?
                                    for var element in currentOptByte.string_values! {
                                        if(element.value! == optBytes[i+1]){
                                            found = element.display_name
                                        }
                                    }
                                    if(found != nil){
                                        stringToDisplay = currentOptByte.name! + " " + found!
                                    }else{
                                        stringToDisplay = currentOptByte.name!
                                    }
                                    
                                    if(cellView?.nodeRunningLabel3.text == nil || cellView?.nodeRunningLabel3.text == " "){
                                        cellView?.nodeRunningLabel3.text = stringToDisplay
                                    } else {
                                        cellView?.nodeRunningLabel3.text = String((cellView?.nodeRunningLabel3.text!.description)! + " " + stringToDisplay)
                                    }
                                    
                                }else if(dbFwOpt![i].format == "enum_icon"){
                                    let iconToDisplay = currentOptByte.icon_values![Int(optBytes[i+1])].icon_code!
                                    //print(iconToDisplay)
                                    if(cellView?.nodeRunningIcon1.isHidden == true){
                                        var found = mMaxIconCode
                                        for var element in currentOptByte.icon_values! {
                                            if(element.value! == optBytes[i+1]){
                                                found = element.icon_code!
                                            }
                                        }
                                        cellView?.nodeRunningIcon1.isHidden = false
                                        cellView?.nodeRunningIcon1.image = mBlueSTSDKv2Icons[found]
                                    }else if(cellView?.nodeRunningIcon2.isHidden == true){
                                        cellView?.nodeRunningIcon2.isHidden = false
                                        cellView?.nodeRunningIcon2.image = mBlueSTSDKv2Icons[iconToDisplay]
                                    }else if(cellView?.nodeRunningIcon3.isHidden == true){
                                        cellView?.nodeRunningIcon3.isHidden = false
                                        cellView?.nodeRunningIcon3.image = mBlueSTSDKv2Icons[iconToDisplay]
                                    }else if(cellView?.nodeRunningIcon4.isHidden == true){
                                        cellView?.nodeRunningIcon4.isHidden = false
                                        cellView?.nodeRunningIcon4.image = mBlueSTSDKv2Icons[iconToDisplay]
                                    }
                                }
                                
                                i=i+1
                            }//for
                        }//if
                    }
                }
            }
        }
        
        node.advertiseInfo
        cellView?.boardName.text = node.name
        cellView?.boardDetails.text = node.addressEx()
        cellView?.boardIsSleepingImage.isHidden = !node.isSleeping
        cellView?.boardHasExtensionImage.isHidden = !node.hasExtension
        cellView?.boardImage.image = node.getTypeImage()
        
        
        return cellView!
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
   public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
       if let selectedFile = urls.first{
           
           do{
               let fileHandler = try FileHandle(forReadingFrom: selectedFile)
               let data = fileHandler.readDataToEndOfFile()
               try fileHandler.close()
               
               do {
                   let decoder = JSONDecoder()

                   if let jsonFw = try? decoder.decode(CustomJSON.self, from: data) {
                      
                       let fwDB = FirmwareDBRequests()
                       
                       if !(jsonFw.bluestsdk_v2 == nil){
                           for fw in jsonFw.bluestsdk_v2! {
                               let fwV2 = fwDB.createBlueSTSDKFirmware(jsonFirmware: fw)
                               /** ADD only Custom Firmware*/
                               if(fwV2.ble_fw_id == "0xFF"){
                                   let fwAdded = localDB.saveNewCustomJsonData(newCustomFw: fwV2)
                                   if(fwAdded){
                                       showToast(message: "Custom Fw Db Entry added.", seconds: 2.0)
                                       tableView.reloadData()
                                   }else {
                                       showToast(message: "Custom Fw Db Already Exsist.", seconds: 2.0)
                                   }
                               }
                           }
                       }else{
                           showToast(message: "A problem occurred.", seconds: 2.0)
                       }

                   }
                   
               } catch {
                   showToast(message: "Invalid JSON.", seconds: 2.0)
                   print("ERROR INTERNAL reading JSON file")
               }
               
           }catch{
               showToast(message: "Invalid JSON.", seconds: 2.0)
               print("ERROR reading JSON file")
           }
       }
   }

   public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){}
   
}

struct CustomJSON: Codable {
    public let bluestsdk_v2: Array<BoardJSONFirmware>?

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
