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

class AILogSetParametersViewController : BlueMSDemoTabViewController{
        
    fileprivate let parameterViewModel = AIDataLogParametersViewModel();
    
    @IBOutlet weak var mFeatureSelectionTable: UITableView!
        
    override func viewDidLoad() {
        mFeatureSelectionTable.delegate = self
        mFeatureSelectionTable.dataSource = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AIDataLogAnnotationViewController {
            vc.node = node
            vc.menuDelegate = menuDelegate
            vc.aiLoggingParameters = parameterViewModel.parameters
        }
        if let vc = segue.destination as? AIDataLogParameterSelectorViewController,
            let data = sender as? AIDataLogParameterSelectorData{
                vc.parameters = data;
            //center the viewcontroller into the parent view controller
            if let popOver = vc.popoverPresentationController,
                let rect = popOver.sourceView?.bounds{
                popOver.sourceRect = rect
            }
        }
    }
    
}

extension AILogSetParametersViewController : UITableViewDataSource,UITableViewDelegate{
    
    private static let FREQUENCY_SECTION_ID = 0
    private static let FREQUENCY_CELL_ID = "AIDataFrequencyParametersViewCell"
    
    private static let FREQUENCY_SECTION_TITLE = {
        return  NSLocalizedString("Sensor Parameters",
                                  tableName: nil,
                                  bundle: Bundle(for: AILogSetParametersViewController.self),
                                  value: "Sensor Parameters",
                                  comment: "Sensor Parameters");
    }();
    
    private static let FEATURE_SECTION_ID = 1
    private static let FEATURE_CELL_ID = "AIDataLogFeatureTableViewCell"
    
    private static let FEATURE_SECTION_TITLE = {
        return  NSLocalizedString("Sensors to log",
                                  tableName: nil,
                                  bundle: Bundle(for: AILogSetParametersViewController.self),
                                  value: "Sensors to log",
                                  comment: "Sensors to log");
    }();
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case AILogSetParametersViewController.FREQUENCY_SECTION_ID:
                return 1
            case AILogSetParametersViewController.FEATURE_SECTION_ID:
                return parameterViewModel.availableFeatures.count
            default:
                return 0
        }
    }
    
    private func createFeatureCell(_ tableView: UITableView, row:Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: AILogSetParametersViewController.FEATURE_CELL_ID) as?
        AIDataLogFeatureTableViewCell
    
        cell?.data=parameterViewModel.availableFeatures[row]
        return cell!
    }

    private func createFrequencyCell(_ tableView: UITableView,row:Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: AILogSetParametersViewController.FREQUENCY_CELL_ID) as?
        AIDataFrequencyParametersViewCell
        
        cell?.parameterViewModel = parameterViewModel

        cell?.displayParametersSelection = { data in self.performSegue(withIdentifier: "AIDataLogParameterSelectorViewController", sender: data)}
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case AILogSetParametersViewController.FREQUENCY_SECTION_ID:
                return createFrequencyCell(tableView, row: indexPath.row)
            case AILogSetParametersViewController.FEATURE_SECTION_ID:
                return createFeatureCell(tableView,row: indexPath.row)
            default:
                return UITableViewCell(); // not used
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case AILogSetParametersViewController.FREQUENCY_SECTION_ID:
            return AILogSetParametersViewController.FREQUENCY_SECTION_TITLE
        case AILogSetParametersViewController.FEATURE_SECTION_ID:
            return AILogSetParametersViewController.FEATURE_SECTION_TITLE
        default:
            return nil
        }
    }
}

