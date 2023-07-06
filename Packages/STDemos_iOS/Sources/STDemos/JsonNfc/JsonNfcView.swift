//
//  JsonNfcView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI

final class JsonNfcView: UIView {
    
    /** TEXT */
    @IBOutlet weak var imgDocText: UIImageView!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var insertTextLabel: UILabel!
    
    @IBOutlet weak var textTF: UITextField!
    @IBOutlet weak var textWriteBtn: UIButton!
    
    /** URL */
    @IBOutlet weak var imgDocUrl: UIImageView!
    @IBOutlet weak var urlTitle: UILabel!
    @IBOutlet weak var insertURLlabel: UILabel!
    
    @IBOutlet weak var headerUrlLabel: UILabel!
    @IBOutlet weak var urlTF: UITextField!    
    @IBOutlet weak var urlHeaderBtn: UIButton!
    @IBOutlet weak var urlWriteBtn: UIButton!

    /** WIFI */
    @IBOutlet weak var imgDocWiFi: UIImageView!
    @IBOutlet weak var wifiTitle: UILabel!
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var authenticationTypeInfoLabel: UILabel!
    @IBOutlet weak var encryptionTypeinfoLabel: UILabel!
 
    @IBOutlet weak var ssidWiFiTF: UITextField!
    @IBOutlet weak var passwordWiFiTF: UITextField!
    @IBOutlet weak var authenticationTypeLabel: UILabel!
    @IBOutlet weak var encryptionTypeLabel: UILabel!
    @IBOutlet weak var authenticationBtn: UIButton!
    @IBOutlet weak var encryptionBtn: UIButton!
    @IBOutlet weak var wifiWriteBtn: UIButton!
    
    /** VCARD */
    @IBOutlet weak var imgDocVcard: UIImageView!
    @IBOutlet weak var vCardTitle: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var formattedNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var workAddressLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var homePhoneLabel: UILabel!
    @IBOutlet weak var workPhoneLabel: UILabel!
    @IBOutlet weak var cellularPhoneLabel: UILabel!
    @IBOutlet weak var homeEmailLabel: UILabel!
    @IBOutlet weak var workEmailLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var nameVCardTF: UITextField!
    @IBOutlet weak var formattedNameVCardTF: UITextField!
    @IBOutlet weak var titleVcardTF: UITextField!
    @IBOutlet weak var organizationVcardTF: UITextField!
    @IBOutlet weak var homeAddressVcardTF: UITextField!
    @IBOutlet weak var workAdressVcardTF: UITextField!
    @IBOutlet weak var addressVcardTF: UITextField!
    @IBOutlet weak var homePhoneVcardTF: UITextField!
    @IBOutlet weak var workPhoneVcardTF: UITextField!
    @IBOutlet weak var cellularPhoneVcardTF: UITextField!
    @IBOutlet weak var homeEmailVcardTF: UITextField!
    @IBOutlet weak var workEmailVcardTF: UITextField!
    @IBOutlet weak var urlVcardTF: UITextField!
    @IBOutlet weak var vcardWriteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textTF.delegate = self
        
        urlTF.delegate = self
        
        ssidWiFiTF.delegate = self
        passwordWiFiTF.delegate = self
        
        nameVCardTF.delegate = self
        formattedNameVCardTF.delegate = self
        titleVcardTF.delegate = self
        organizationVcardTF.delegate = self
        homeAddressVcardTF.delegate = self
        workAdressVcardTF.delegate = self
        addressVcardTF.delegate = self
        homePhoneVcardTF.delegate = self
        workPhoneVcardTF.delegate = self
        cellularPhoneVcardTF.delegate = self
        homeEmailVcardTF.delegate = self
        workEmailVcardTF.delegate = self
        urlVcardTF.delegate = self
        
        if let docTextImg = UIImage(systemName: "doc.text")?.maskWithColor(color: ColorLayout.primary.light) {
            imgDocText.image = docTextImg
            imgDocUrl.image = docTextImg
            imgDocWiFi.image = docTextImg
            imgDocVcard.image = docTextImg
        }
        
        textTitle.text = Localizer.JsonNfc.Text.textTitle.localized
        insertTextLabel.text = Localizer.JsonNfc.Text.insertText.localized
        
        urlTitle.text = Localizer.JsonNfc.Text.urlTitle.localized
        insertURLlabel.text = Localizer.JsonNfc.Text.insertUrl.localized
        headerUrlLabel.text = Localizer.JsonNfc.Url.http.localized
        
        wifiTitle.text = Localizer.JsonNfc.Text.wifiTitle.localized
        ssidLabel.text = Localizer.JsonNfc.Text.ssid.localized
        passwordLabel.text = Localizer.JsonNfc.Text.password.localized
        authenticationTypeInfoLabel.text = Localizer.JsonNfc.Text.authenticationType.localized
        authenticationTypeLabel.text = Localizer.JsonNfc.Authentication.none.localized
        encryptionTypeinfoLabel.text = Localizer.JsonNfc.Text.encryptionType.localized
        encryptionTypeLabel.text = Localizer.JsonNfc.Encryption.none.localized
        
        vCardTitle.text = Localizer.JsonNfc.Text.vCardTitle.localized
        nameLabel.text = Localizer.JsonNfc.Text.name.localized
        formattedNameLabel.text = Localizer.JsonNfc.Text.formattedName.localized
        titleLabel.text = Localizer.JsonNfc.Text.title.localized
        organizationLabel.text = Localizer.JsonNfc.Text.organization.localized
        homeAddressLabel.text = Localizer.JsonNfc.Text.homeAddress.localized
        workAddressLabel.text = Localizer.JsonNfc.Text.workAddress.localized
        addressLabel.text = Localizer.JsonNfc.Text.address.localized
        homePhoneLabel.text = Localizer.JsonNfc.Text.homePhone.localized
        workPhoneLabel.text = Localizer.JsonNfc.Text.workPhone.localized
        cellularPhoneLabel.text = Localizer.JsonNfc.Text.cellularPhone.localized
        homeEmailLabel.text = Localizer.JsonNfc.Text.homeEmail.localized
        workEmailLabel.text = Localizer.JsonNfc.Text.workEmail.localized
        urlLabel.text = Localizer.JsonNfc.Text.url.localized
        
        let chevronDownImg = UIImage(systemName: "chevron.down")?.maskWithColor(color: ColorLayout.primary.light)
        urlHeaderBtn.setImage(chevronDownImg, for: .normal)
        authenticationBtn.setImage(chevronDownImg, for: .normal)
        encryptionBtn.setImage(chevronDownImg, for: .normal)
        
        let writeToNfcTitleButton = Localizer.JsonNfc.Action.writeToNfc.localized
        Buttonlayout.standard.apply(to: textWriteBtn, text: writeToNfcTitleButton)
        Buttonlayout.standard.apply(to: urlWriteBtn, text: writeToNfcTitleButton)
        Buttonlayout.standard.apply(to: wifiWriteBtn, text: writeToNfcTitleButton)
        Buttonlayout.standard.apply(to: vcardWriteBtn, text: writeToNfcTitleButton)
    }
    
    
}

extension JsonNfcView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
