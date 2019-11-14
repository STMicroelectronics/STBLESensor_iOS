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

class BlueMSMultiNetworkViewController : BlueMSDemoTabViewController {
    
    @IBOutlet weak var humanActivityView: UIView!
    @IBOutlet weak var humanActivityImage: UIImageView!
    @IBOutlet weak var humanActivityDesc: UILabel!
    
    @IBOutlet weak var audioSceneView: UIView!
    @IBOutlet weak var audioSceneImage: UIImageView!
    @IBOutlet weak var audioSceneDesc: UILabel!
    
    @IBOutlet weak var algorithnSelectionView: UIView!
    @IBOutlet weak var currentAlgorithmLabel: UILabel!
    
    private let mAudioSceneVM = AudioSceneClassificaitonModelView()
    private let mActiviyRecognitionVM = ActivityRecognitionModelView()
    private var mMultiNNViewModel: MultiNeuralNetworkViewModel?
    
    private static let TIME_FORMAT:DateFormatter = {
        var timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        humanActivityView.isHidden = true
        audioSceneView.isHidden = true
        attachAudioSceneViewModel()
        attachActivityRecognitionViewModel()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let audioFeature = self.node.getFeatureOfType(BlueSTSDKFeatureAudioCalssification.self) as? BlueSTSDKFeatureAudioCalssification
        let activityFeature = self.node.getFeatureOfType(BlueSTSDKFeatureActivity.self) as? BlueSTSDKFeatureActivity
        
        mActiviyRecognitionVM.attachListener(feature: activityFeature)
        mAudioSceneVM.attachListener(feature: audioFeature)
        if(mMultiNNViewModel == nil){
            mMultiNNViewModel = MultiNeuralNetworkViewModel(node: self.node)
            mMultiNNViewModel?.loadAvailableAlgorithm()
        }
        attachMultiNNViewModel()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let audioFeature = self.node.getFeatureOfType(BlueSTSDKFeatureAudioCalssification.self) as? BlueSTSDKFeatureAudioCalssification
        let activityFeature = self.node.getFeatureOfType(BlueSTSDKFeatureActivity.self) as? BlueSTSDKFeatureActivity
        
        mActiviyRecognitionVM.removeListener(feature: activityFeature)
        mAudioSceneVM.removeListener(feature: audioFeature)
    }
    
    private func attachAudioSceneViewModel(){
        mAudioSceneVM.onSetVisibiltiy = { [weak audioSceneView] isVisble in
            audioSceneView?.isHidden = !isVisble
        }
        
        mAudioSceneVM.onStateChange = { [weak self] newState in
            self?.audioSceneImage.image = newState.icon
            let time = BlueMSMultiNetworkViewController.TIME_FORMAT.string(from:Date())
            self?.audioSceneDesc.text = String(format:"%@: %@",time,newState.description)
        }
    }
    
    private func attachActivityRecognitionViewModel(){
        mActiviyRecognitionVM.onSetVisibiltiy = { [weak humanActivityView] isVisble in
            humanActivityView?.isHidden = !isVisble
        }
        
        mActiviyRecognitionVM.onStateChange = { [weak self] newActivity in
            self?.humanActivityImage.image = newActivity.icon
            let time = BlueMSMultiNetworkViewController.TIME_FORMAT.string(from:Date())
            self?.humanActivityDesc.text = String(format:"%@: %@",time,newActivity.description)
        }
    }
    
    private func attachMultiNNViewModel(){
        guard let vm = mMultiNNViewModel else{
            return
        }
        vm.onCurrentAlgorithmChange = { [weak self] newAlgo in
            self?.currentAlgorithmLabel.text =
                String(format: BlueMSMultiNetworkViewController.CURRENT_ALGORITHM_FORMAT, newAlgo.name)
        }
        
        vm.onAvailableAlgorithmListLoaded = { newList in
            if let first = newList?.first,
                vm.currentAlgorithm != first{
                vm.selectAlgorithm(first)
            }
        }
        
        algorithnSelectionView.isHidden = !vm.showAlgorithmListChange
        vm.onShowAlgorithmListChange = { [weak self] showAlgoSelector in
            self?.algorithnSelectionView.isHidden = !showAlgoSelector
        }
    }
    
    @IBAction func onChangeAlgorithmClicked(_ sender: UIButton) {
        guard let algos = mMultiNNViewModel?.availableAlgos else {
            return
        }
        let currentAlgo = mMultiNNViewModel?.currentAlgorithm
        let vc = BlueMSAIAlgorithmSelectorViewController.instantiate(algos: algos, currentAlgo: currentAlgo){
            algo in
                self.mMultiNNViewModel?.selectAlgorithm(algo)
        }
        present(vc, animated: true, completion: nil)
    }
    
    private static let CURRENT_ALGORITHM_FORMAT = {
        return  NSLocalizedString("Current Algorithm: %@",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Current Algorithm: %@",
                                  comment: "Current Algorithm: %@")
    }();
    
}
