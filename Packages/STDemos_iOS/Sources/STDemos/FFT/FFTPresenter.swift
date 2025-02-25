//
//  FFTPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import DGCharts

final class FFTPresenter: DemoPresenter<FFTViewController> {
    var fftDetails: FFTDetails = FFTDetails(fftPoint: nil, fftTimeDataInfo: nil)
    var timeDomainStats:FFTTimeDataInfo? = nil
    var maxPoint:[FFTPoint]? = nil
}

// MARK: - FFTViewControllerDelegate
extension FFTPresenter: FFTDelegate {

    func load() {
        demo = .fft
        
        demoFeatures = param.node.characteristics.features(with: Demo.fft.features)
        
        view.configureView()
    }
    
    func updateFFT(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<FFTAmplitudeData>,
           let data = sample.data {
            didFFTUpdate(data)
        } else if let sample = sample as? FeatureSample<MotorTimeParametersData>,
            let data = sample.data {
            didMotorParametersUpdate(data)
        }
    }
    
    func detailButtonTapped() {
        let alertAction = AlertActionClosure(
            title: "Close",
            completion: {_ in }
        )

        let controller = FFTStatsPresenter(param: AlertFFTDetails(fftDetails: fftDetails, callback: alertAction)).start()

        controller.modalPresentationStyle = .overFullScreen

        view.present(controller, animated: true)
    }
    
    private func didFFTUpdate(_ data: FFTAmplitudeData) {
        let isComplete = data.isCompleted
        if(isComplete){
            let lineConf = LINE_CONFIG
            if let numberOfComponents = data.numberOfComponents.value {
                let nComponents = min(Int(numberOfComponents), lineConf.count)
                if let freqSteps = data.frequencyStep.value {
                    let fftData = (0..<nComponents).compactMap{ i in
                        return data.getComponent(index: i)
                    }
                    updateChart(fftData,freqSteps)
                    updateStats(fftData,freqSteps)
                }
            }
        }else{
            if let percentage = data.dataLoadPercentage.value {
                updateProgres(percentage)
            }
        }
    }

    private func updateProgres(_ percentage:UInt8){
        DispatchQueue.main.async {
            self.view.fftProgress.isHidden=false
            self.view.fftProgress.progress = Float(percentage)/100.0
        }
    }
    
    private func updateChart(_ fftData:[[Float]],_ freqSteps:Float){
    
        let dataSets:[LineChartDataSet] = zip(LINE_CONFIG,fftData).compactMap{ line,data in
            return buildDataSet(conf: line, yData: data, deltaX: freqSteps)
        }
       
        DispatchQueue.main.async {
            self.view.fftProgress.isHidden=true
            self.view.chart.data = LineChartData(dataSets: dataSets)
        }
    }

    private func updateStats(_ fftData:[[Float]],_ freqSteps:Float){
        self.maxPoint = fftData.map{ values in
            let maxIndex = values.indexMax()
            let maxValue = values[maxIndex]
            let maxFreq = Float(maxIndex)*freqSteps
            return FFTPoint(frequency:maxFreq,amplitude:maxValue)
        }
        
        fftDetails.fftPoint = self.maxPoint
    }
    
    private func buildDataSet(conf:LineConfig, yData:[Float],deltaX:Float) -> LineChartDataSet{
        let data = yData.enumerated().map{ ChartDataEntry(x: Double($0.offset)*Double(deltaX),y: Double($0.element))}
        let line =  LineChartDataSet(entries: data,label: conf.name)
        line.drawCirclesEnabled=false
        line.drawIconsEnabled=false
        line.drawValuesEnabled=false
        line.setDrawHighlightIndicators(false)
        line.lineWidth=2.0
        line.setColor(conf.color)
        
        return line
    }
    
    private func didMotorParametersUpdate(_ data: MotorTimeParametersData) {
        timeDomainStats = FFTTimeDataInfo (
            accX: data.accX.value?.description,
            accY: data.accY.value?.description,
            accZ: data.accZ.value?.description,
            speedX: data.speedX.value?.description,
            speedY: data.speedY.value?.description,
            speedZ: data.speedZ.value?.description
        )
        
        fftDetails.fftTimeDataInfo = timeDomainStats
    }

}

let LINE_CONFIG = [
    LineConfig(name:"X",color:ColorLayout.red.light),
    LineConfig(name:"Y",color:ColorLayout.green.light),
    LineConfig(name:"Z",color:ColorLayout.blue.light),
]

fileprivate extension Array where Element == Float {
    
    func indexMax() -> Int{
        var maxValue = self[0]
        var index = 0
        for i in 1..<count{
            if(self[i]>maxValue){
                maxValue = self[i]
                index = i
            }
        }
        return index;
    }
    
}
