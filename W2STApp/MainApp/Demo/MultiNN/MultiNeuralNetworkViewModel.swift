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

struct AvailableAlgorithm : Equatable{
    let index:Int
    let name:String
    
    static func == (lhs: AvailableAlgorithm, rhs: AvailableAlgorithm) -> Bool {
        return lhs.index == rhs.index
    }
}

class MultiNeuralNetworkViewModel {
    
    private let mActivityNN:BlueSTSDKFeature?
    private let mAudioSceneNN:BlueSTSDKFeature?
    private let mConsole:MultiNeuralNetworkConsole
    private(set) var availableAlgos:[AvailableAlgorithm]? {
        didSet {
            showAlgorithmListChange = availableAlgos != nil
            DispatchQueue.main.async {
                self.onAvailableAlgorithmListLoaded?(self.availableAlgos)
            }
        }
    }
    
    private(set) var showAlgorithmListChange:Bool = false {
        didSet{
            DispatchQueue.main.async {
                self.onShowAlgorithmListChange?(self.showAlgorithmListChange)
            }
        }
    }
    
    private(set) var currentAlgorithm:AvailableAlgorithm? {
        didSet{
            DispatchQueue.main.async {
                if let algo = self.currentAlgorithm{
                    self.onCurrentAlgorithmChange?(algo)
                }
            }
        }
    }
    
    var onCurrentAlgorithmChange:((AvailableAlgorithm)->())?
    var onShowAlgorithmListChange:((Bool)->())?
    var onAvailableAlgorithmListLoaded:(([AvailableAlgorithm]?)->())?
    
    init(node: BlueSTSDKNode){
        mActivityNN = node.getFeatureOfType(BlueSTSDKFeatureActivity.self)
        mAudioSceneNN = node.getFeatureOfType(BlueSTSDKFeatureAudioCalssification.self)
        mConsole = MultiNeuralNetworkConsole(console: node.debugConsole!)
    }
    
    private func enableNotification(){
        mAudioSceneNN?.enableNotification()
        mActivityNN?.enableNotification()
        
    }
    
    private func disableNotification(){
        mAudioSceneNN?.disableNotification()
        mActivityNN?.disableNotification()
        
    }
    
    private func findAlgoWithIndex(_ index:Int) -> AvailableAlgorithm?{
        return availableAlgos?.first{ $0.index == index}
    }
    
    public func getCurrentAlgorithm(){
        _ = mConsole.getCurrentAlgorithmIndex{ [weak self] index in
            guard let algoIndex = index,
                let algo = self?.findAlgoWithIndex(algoIndex) else{
                return
            }
            self?.currentAlgorithm = algo
        }
    }
    
    public func selectAlgorithm( _ algo:AvailableAlgorithm){
        disableNotification()
        _ = mConsole.enableAlgorithm(algo){
            self.currentAlgorithm = algo
            self.enableNotification()
        }
    }
    
    public func loadAvailableAlgorithm(){
        guard availableAlgos == nil else{
            DispatchQueue.main.async {
                self.onAvailableAlgorithmListLoaded?(self.availableAlgos)
            }
            return
        }
        
        _ = mConsole.getAvailableAlgorithms{ [weak self] algos in
            self?.availableAlgos = algos
            if(algos == nil){
                // if only one algorithm is present enable the notification, otherwise wait the
                // algorithm selection
                self?.enableNotification()
            }
        }
    }
    
    
    
}
