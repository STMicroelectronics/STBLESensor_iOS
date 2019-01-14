//
//  FFTAmplitudeViewController.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 03/12/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation
import UIKit
import Charts

class FFTAmplitudeViewController : BlueMSDemoTabViewController{
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var loadProgress: UIProgressView!
    @IBOutlet weak var xStatsLabel: UILabel!
    @IBOutlet weak var yStatsLabel: UILabel!
    @IBOutlet weak var zStatsLabel: UILabel!
    
    private var feature:BlueSTSDKFeatureFFTAmplitude?
    
    private func setUpCharts(){
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.chartDescription?.enabled=false
        chart.isMultipleTouchEnabled=false
        let legend = chart.legend
        legend.drawInside = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
    }
    
    override func viewDidLoad() {
        setUpCharts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProgress.progress=0.0
        feature = node.getFeatureOfType(BlueSTSDKFeatureFFTAmplitude.self) as? BlueSTSDKFeatureFFTAmplitude
        feature?.add(self)
        _ = feature?.enableNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        feature?.remove(self)
        _ = feature?.disableNotification()
    }
}


extension FFTAmplitudeViewController : BlueSTSDKFeatureDelegate{
    
    private static let MAX_FORMAT = "%@ Max: %.4f @ %.2f Hz"
    
    private struct LineConfig{
        let name:String
        let color:UIColor
    }
    
    static private let LINE_CONFIG = [
        LineConfig(name:"X",color:UIColor.red),
        LineConfig(name:"Y",color:UIColor.green),
        LineConfig(name:"Z",color:UIColor.blue),
    ]
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let isComplete = BlueSTSDKFeatureFFTAmplitude.isComplete(sample)
        let percentage = BlueSTSDKFeatureFFTAmplitude.getDataLoadPercentage(sample)
        let nSample = BlueSTSDKFeatureFFTAmplitude.getNSample(sample)
        let freqStep = BlueSTSDKFeatureFFTAmplitude.getFrequencySteps(sample)
        let nComponents = BlueSTSDKFeatureFFTAmplitude.getNComponents(sample)
        DispatchQueue.main.async {
            self.debugLabel.text = "IsComplete: \(isComplete)\nPercentage:\(percentage)\nnSample:\(nSample)\nFreqStep:\(freqStep)\nnComponents:\(nComponents)"
        }
        if(isComplete){
            let lineConf = FFTAmplitudeViewController.LINE_CONFIG
            let nComponents = min(Int(BlueSTSDKFeatureFFTAmplitude.getNComponents(sample)),lineConf.count)
            let freqSteps = BlueSTSDKFeatureFFTAmplitude.getFrequencySteps(sample)
            let fftData = (0..<nComponents).compactMap{ i in
                return BlueSTSDKFeatureFFTAmplitude.getComponent(sample, index: i)
            }
            updateChart(fftData,freqSteps)
            updateStats(fftData,freqSteps)
        }else{
            updateProgres(percentage)
        }
    }
    
    private func updateChart(_ fftData:[[Float]],_ freqSteps:Float){
        let lineConf = FFTAmplitudeViewController.LINE_CONFIG
        let dataSets:[ILineChartDataSet] = zip(lineConf,fftData).compactMap{ line,data in
            return buildDataSet(conf: line, yData: data, deltaX: freqSteps)
        }
       
        DispatchQueue.main.async {
            self.loadProgress.isHidden=true
            self.chart.data = LineChartData(dataSets: dataSets)
        }
    }
    
    private func updateStats(_ fftData:[[Float]],_ freqSteps:Float){
        let lineConf = FFTAmplitudeViewController.LINE_CONFIG
        
        let texts = zip(lineConf, fftData).map{ (arg) -> String in
            let (lineConf, values) = arg
            let maxIndex = values.indexMax()
            let maxValue = values[maxIndex]
            let maxFreq = Float(maxIndex)*freqSteps
            return String(format: FFTAmplitudeViewController.MAX_FORMAT,
                          lineConf.name,maxValue,maxFreq)
        }
        
        DispatchQueue.main.async {
            
            let labels = [self.xStatsLabel,self.yStatsLabel,self.zStatsLabel]
            labels.forEach{ $0?.isHidden = true}
            
            zip(labels,texts).forEach{ label, value in
                label?.isHidden = false
                label?.text = value
            }
        }
        
    }
   
    private func buildDataSet(conf:LineConfig, yData:[Float],deltaX:Float) -> ILineChartDataSet{
        let data = yData.enumerated().map{ ChartDataEntry(x: Double($0.offset)*Double(deltaX),y: Double($0.element))}
        let line =  LineChartDataSet(values: data,label: conf.name)
        line.drawCirclesEnabled=false
        line.drawIconsEnabled=false
        line.drawValuesEnabled=false
        line.setDrawHighlightIndicators(false)
        line.lineWidth=2.0
        line.setColor(conf.color)
        
        return line
    }
    
    private func updateProgres(_ percentage:UInt8){
        DispatchQueue.main.async {
            self.loadProgress.isHidden=false
            self.loadProgress.progress = Float(percentage)/100.0
        }
    }
    
}

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
