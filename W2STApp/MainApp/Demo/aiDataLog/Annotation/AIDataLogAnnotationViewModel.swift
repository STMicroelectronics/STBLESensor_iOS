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
import BlueSTSDK

class AIDataLogAnnotationViewModel : NSObject{
    
    var onAnnotationsDataChanges:(()->())? = nil
    var onLogStart:(()->())? = nil
    var onLogStop:(()->())? = nil
    var onIOError:(()->())? = nil
    var onMissingSDError:(()->())? = nil
    
    
    private let annotationRepository = AnnotationRepository(storage: AnnoationStorageKeyArchived.sharedInstance)
    
    lazy var annotations:[SelectableAnnotation] = {
        return annotationRepository.annotations.map{ SelectableAnnotation(annotation: $0)}
    }()
    
    private var mFeature:BlueSTSDKFeatureAILogging?
    private var isLogging = false;
    
    func start(with node:BlueSTSDKNode){
        mFeature = node.getFeatureOfType(BlueSTSDKFeatureAILogging.self) as? BlueSTSDKFeatureAILogging
        if let feature = mFeature{
            feature.add(self)
            node.enableNotification(feature)
        }
    }
    
    func stop(){
        if let feature = mFeature{
            feature.parentNode.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
            feature.remove(self)
        }
    }
    
    func add(annotation:Annotation){
        annotationRepository.add(annotation)
        annotations.append(SelectableAnnotation(annotation: annotation))
        onAnnotationsDataChanges?()
    }
    
    func remove(annotation:SelectableAnnotation){
        annotationRepository.remove(annotation.annotation)
        annotations.remove(annotation)
        onAnnotationsDataChanges?()
    }
    
    func select(annotation:Annotation){
        guard isLogging else{
            return
        }
        logAnnotationEnabled(annotation)
    }
    
    func deselect(annotation:Annotation){
        guard isLogging else{
            return
        }
        logAnnotationDisabled(annotation)
    }
    
    private func syncNodeTime(){
        if let console = mFeature?.parentNode.debugConsole {
            NucleoConsole(console).setDateAndTime(date: Date());
        }
    }
    
    private func logAnnotationEnabled(_ annotation:Annotation){
        mFeature?.updateAnnotation(">"+annotation.label)
    }
    
    private func logAnnotationDisabled(_ annotation:Annotation){
        mFeature?.updateAnnotation("<"+annotation.label)
    }
    
    private func syncEnabledAnnotation(){
        annotations.filter{ $0.isSelected }.forEach{
            logAnnotationEnabled($0.annotation)
        }
    }
    
    func changeLogStatus(param: BlueSTSDKFeatureAILogging.Parameters){
        if(!isLogging){
            syncNodeTime()
            mFeature?.startLogging(param)
            syncEnabledAnnotation()
        }else{
            mFeature?.stopLogging()
        }
    }
}


extension AIDataLogAnnotationViewModel : BlueSTSDKFeatureDelegate{
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let status = BlueSTSDKFeatureAILogging.getLoggingStatus(sample)
        isLogging = BlueSTSDKFeatureAILogging.isLogging(sample)
        print(status)
        DispatchQueue.main.async { [weak self] in
            switch(status){
            case .stoped:
                self?.onLogStop?()
            case .started:
                self?.onLogStart?()
            case .missingSD:
                self?.mFeature?.stopLogging()
                self?.onMissingSDError?()
            case .ioError:
                self?.mFeature?.stopLogging()
                self?.onIOError?()
            case .upgrede,.unknown:
                return
            }
        }
    }
    
}

fileprivate extension Array where Element == SelectableAnnotation {
    
    mutating func remove(_ item:SelectableAnnotation){
        if let index = self.firstIndex(where: { item.annotation == $0.annotation}){
            remove(at:index)
        }
    }
}
