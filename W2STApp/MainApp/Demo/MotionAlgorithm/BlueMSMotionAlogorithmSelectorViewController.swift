/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

class BlueMSMotionAlogorithmSelectorViewController : UIViewController, UITableViewDelegate{
    
    public static func instantiate( onSelection:@escaping (BlueSTSDKFeatureMotionAlogrithm.Algorithm)->())-> UIViewController{
        let storyboard = UIStoryboard(name: "MotionAlogorinthm", bundle: Bundle(for: BlueMSMotionAlogorithmSelectorViewController.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: "BlueMSMotionAlogorithmSelectorViewController") as! BlueMSMotionAlogorithmSelectorViewController
        vc.onAlgoSelectionCallback = onSelection
        return vc
    }
    
    @IBOutlet weak var algorithmsTable: UITableView!
    
    fileprivate var onAlgoSelectionCallback:((BlueSTSDKFeatureMotionAlogrithm.Algorithm)->())?=nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        algorithmsTable.dataSource = self
        algorithmsTable.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlgo = BlueSTSDKFeatureMotionAlogrithm.Algorithm.allCases[indexPath.row]
        onAlgoSelectionCallback?(selectedAlgo)
        removeCurrentViewController()
    }
    
}


extension BlueMSMotionAlogorithmSelectorViewController : UITableViewDataSource{
    private static let CELL_ID = "motionAlgo_algoCellId"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlueSTSDKFeatureMotionAlogrithm.Algorithm.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlueMSMotionAlogorithmSelectorViewController.CELL_ID)
        cell?.textLabel?.text = BlueSTSDKFeatureMotionAlogrithm.Algorithm.allCases[indexPath.row].description
        return cell!
    }
}


