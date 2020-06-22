//
//  BlueMSCloudConfigDetailsViewController.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 03/11/2017.
//  Copyright © 2017 STMicroelectronics. All rights reserved.
//

import Foundation

public class BlueMSCloudConfigDetailsViewController : W2STCloudConfigViewController{
    
    private static let SHOW_DETAILS = {
        return  NSLocalizedString("Show Details",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConfigDetailsViewController.self),
                                  value: "Show Details",
                                  comment: "Show Details");
    }();

    private static let HIDE_DETAILS = {
        return  NSLocalizedString("Hide Details",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConfigDetailsViewController.self),
                                  value: "Hide Details",
                                  comment: "Hide Details");
    }();

    @IBOutlet weak var mShowDetailsButton: UIButton!
    @IBOutlet weak var mDetailsView: UIView!
    
    @IBAction func onShowDetailsClick(_ sender: UIButton) {
        mDetailsView.isHidden = !mDetailsView.isHidden;
        if(mDetailsView.isHidden){
            mShowDetailsButton.setTitle(BlueMSCloudConfigDetailsViewController.SHOW_DETAILS, for: .normal)
        }else{
            mShowDetailsButton.setTitle(BlueMSCloudConfigDetailsViewController.HIDE_DETAILS, for: .normal)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad();
        mShowDetailsButton.isHidden = true;
        mDetailsView.isHidden = false;
    }
    
    public func showDetailsButton(){
        mShowDetailsButton.setTitle(BlueMSCloudConfigDetailsViewController.SHOW_DETAILS, for: .normal)
        mShowDetailsButton.isHidden = false;
        mDetailsView.isHidden = true;
    }
    
}
