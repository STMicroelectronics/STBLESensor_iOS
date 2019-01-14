//
//  BlueMSNucleoPrefViewController.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 31/10/2017.
//  Copyright © 2017 STMicroelectronics. All rights reserved.
//

import Foundation
import BlueSTSDK

public class BlueMSNucleoPrefViewController : UITableViewController{
    private static let SET_NAME_SEGUE = "BlueMSPrefSetNameSegue"
        
    @IBOutlet weak var mChangeNameCell: UITableViewCell!
    @IBOutlet weak var mSyncTimeCell: UITableViewCell!
    
    @objc public var node:BlueSTSDKNode?;
    
    public override func viewDidLoad() {
        self.tableView.delegate = self;
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath);
        if(cell == mSyncTimeCell){
            onSyncTimeSelected()
        }
        if(cell == mChangeNameCell){
            onChangeNameSelected()
        }
        
    }
    
    private func onSyncTimeSelected(){
        let console = node?.debugConsole;
        if let console = console{
            let nucleoConsole = NucleoConsole(console);
            nucleoConsole.setDateAndTime(date: Date());
            showAllert(title: "Sync Time", message:"Sync done" )
        }else{
            showAllert(title: "Sync Time", message:"Impossible do the sync")
        }
    }
    
    private func onChangeNameSelected(){
        performSegue(withIdentifier: BlueMSNucleoPrefViewController.SET_NAME_SEGUE, sender: self)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == BlueMSNucleoPrefViewController.SET_NAME_SEGUE){
            let dest = segue.destination as! BlueMSNucleoPrefSetNameViewController;
            dest.node = node;
        }
    }
}
