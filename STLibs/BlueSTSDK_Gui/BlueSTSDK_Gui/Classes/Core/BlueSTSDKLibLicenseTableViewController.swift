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

import Foundation
import UIKit


/// class showing a list of license used by the application
public class BlueSTSDKLibLicenseViewController: UITableViewController{
    
    /// Segue to see the license details
    private static let LICENSES_DETAILS_VIEW_CONTROLLER_SEGUE = "bluestsdk_show_lib_licenses_details";

    /// table cell identifier
    private static let CELL_IDENTIFIER = "LicenseDetailsTableCell"

    
    /// list of license to display
    public var licensePath:[BlueSTSDKLibLicense]?
    
    /// user selected license
    private var selectedItem:IndexPath?;

    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = licensePath{
            return items.count;
        }else {
            return 0;
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: BlueSTSDKLibLicenseViewController.CELL_IDENTIFIER,
                for: indexPath);

        let index = indexPath.row;
        if let items = licensePath {
            cell.textLabel?.text = items[index].libName;
        }

        return cell;
    }

    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedItem = indexPath;
        performSegue(withIdentifier: BlueSTSDKLibLicenseViewController.LICENSES_DETAILS_VIEW_CONTROLLER_SEGUE, sender: self)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == BlueSTSDKLibLicenseViewController.LICENSES_DETAILS_VIEW_CONTROLLER_SEGUE ){
            let destinationViewController = segue.destination as! BlueSTSDKLibLicenseDetailsViewController;
            if let items = licensePath, let selected = selectedItem{
                destinationViewController.title = items[selected.row].libName;
                destinationViewController.licenseFilePath = items[selected.row].libLicensePath;
            }
        }
    }


}
