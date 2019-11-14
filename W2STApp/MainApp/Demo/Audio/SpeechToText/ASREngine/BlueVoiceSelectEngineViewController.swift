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

protocol BlueVoiceSelectEngineDelegate {
    func onEngineSelected(engine: BlueVoiceASRDescription, language: BlueVoiceLanguage);
    func getAvailableEngine()->[BlueVoiceASRDescription]
}

public class BlueVoiceSelectEngineViewController: UIViewController,UITableViewDelegate{
        
    private var mEngineDataSource : EngineDataSource?;
    private var mLanguageDataSource : LanguageDataSource?;
    private var mSelectedEngine: BlueVoiceASRDescription?;
    @IBOutlet weak var mEngineList: UITableView!
    
    var delegate:BlueVoiceSelectEngineDelegate!;
    
    public override func viewDidLoad() {
        super.viewDidLoad();
        mEngineList.delegate = self;
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        mEngineDataSource = EngineDataSource(delegate.getAvailableEngine());
        mLanguageDataSource = nil;
        mEngineList.dataSource = mEngineDataSource;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if(mSelectedEngine == nil){
            let desc = mEngineDataSource!.getEngine(indexPath);
            mEngineDataSource=nil;
            mSelectedEngine=desc;
            if(desc.supportedLanguages.count==1){
                delegate?.onEngineSelected(engine: desc, language: desc.supportedLanguages[0]);
                self.dismiss(animated: true, completion: nil);
            }else{
                mLanguageDataSource =  LanguageDataSource(desc.supportedLanguages);
                tableView.dataSource = mLanguageDataSource;
                tableView.reloadData();
            }
        }else{
            let lang = mLanguageDataSource?.getLanguage(indexPath)
            delegate?.onEngineSelected(engine: mSelectedEngine!, language: lang!);
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    private class EngineDataSource :NSObject, UITableViewDataSource ,UITableViewDelegate{
        
        private let mEngines:[BlueVoiceASRDescription];
        private var mLanguageDataSource:LanguageDataSource? ;
        public init( _ engines:[BlueVoiceASRDescription]){
            mEngines = engines;
        }
        
        public func getEngine(_ index:IndexPath)->BlueVoiceASRDescription{
            return mEngines[index.row];
        }
        
        //
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return mEngines.count;
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlueVoiceEngineCell", for: indexPath)
            
            let desc = mEngines[indexPath.row];
            cell.textLabel?.text = desc.name;
            if(desc.supportedLanguages.count==1){
                cell.accessoryType = .none;
            }else{
                cell.accessoryType = .disclosureIndicator;
            }
            return cell
        }
    }
    
    private class LanguageDataSource :NSObject, UITableViewDataSource, UITableViewDelegate{
        
        private let mLanguages:[BlueVoiceLanguage];
        
        public init( _ languages:[BlueVoiceLanguage]){
            mLanguages = languages;
        }
        
        public func getLanguage(_ index: IndexPath)->BlueVoiceLanguage{
            return mLanguages[index.row];
        }
        
        //
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return mLanguages.count;
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlueVoiceEngineCell", for: indexPath)
            
            cell.selectionStyle = .none;
            cell.textLabel?.text = mLanguages[indexPath.row].rawValue;
            cell.accessoryType = .disclosureIndicator;
            
            return cell
        }
    }
}
