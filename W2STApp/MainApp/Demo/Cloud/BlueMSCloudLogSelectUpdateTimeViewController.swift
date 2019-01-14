/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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


protocol BlueMSCloudLogSelectUpdateTimeDelegate {
    func onUpdateTimeSelected(updateTime:TimeInterval);
}

public class BlueMSCloudLogSelectUpdateTimeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    private static let POSSIBLE_UPDATE_TIME:[TimeInterval] = [0.0,0.5,1.0,3.0,5.0,10.0]
    
    @IBOutlet weak var mTimeIntervalList: UITableView!
    
    var delegate:BlueMSCloudLogSelectUpdateTimeDelegate?;
    var currentUpdateInterval:TimeInterval?
    
    public override func viewDidLoad() {
        super.viewDidLoad();
        mTimeIntervalList.delegate = self
        mTimeIntervalList.dataSource = self
        mTimeIntervalList.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let interval = BlueMSCloudLogSelectUpdateTimeViewController.POSSIBLE_UPDATE_TIME[indexPath.row]
        delegate?.onUpdateTimeSelected(updateTime: interval)
        self.dismiss(animated: true, completion: nil)
    }
    

    //
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlueMSCloudLogSelectUpdateTimeViewController.POSSIBLE_UPDATE_TIME.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: "cloudLog_timeIntervalCell");
        
        if (cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "cloudLog_timeIntervalCell");
            cell?.selectionStyle = .none;
        }
        let interval = BlueMSCloudLogSelectUpdateTimeViewController.POSSIBLE_UPDATE_TIME[indexPath.row];
        cell?.textLabel?.text = String(format: "%.1f s",interval);
        if(currentUpdateInterval == interval){
            cell?.accessoryType = .checkmark
        }
        return cell!
    }

}

