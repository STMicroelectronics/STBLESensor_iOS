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
import UIKit
import Charts

class FFTAmplitudeViewController : BlueMSDemoTabViewController{
   
    
    
    private static let DATA_ACQUISITION = {
        return  NSLocalizedString("Data acquisition ongoing…",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTAmplitudeViewController.self),
                                  value: "Data acquisition ongoing…",
                                  comment: "Data acquisition ongoing…");
    }()
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var detailsDialogPlaceHolder: UIView!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var loadProgress: UIProgressView!
    
    private var fftFeature:BlueSTSDKFeatureFFTAmplitude? = nil
    private var timeDomainFeature:BlueSTSDKFeatureMotorTimeParameters?=nil
    
    private var maxPoint:[FFTPoint]? = nil
    private var timeDomainStats:TimeDomainStats? = nil
    
    private func setUpCharts(){
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart.chartDescription?.enabled=false
        chart.isMultipleTouchEnabled=false
        chart.noDataText = FFTAmplitudeViewController.DATA_ACQUISITION
        
        let legend = chart.legend
        legend.drawInside = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        if #available(iOS 13, *){
            chart.noDataTextColor = UIColor.label
            chart.xAxis.labelTextColor = UIColor.label
            chart.leftAxis.labelTextColor = UIColor.label
            legend.textColor = .label
        }
    }
    
    private func findDemoViewController()->BlueSTSDKDemoViewController?{
        var parentVc = parent;
        while (parentVc != nil){
            if let demoVc = parentVc as? BlueSTSDKDemoViewController{
                return demoVc
            }else{
                parentVc = parentVc?.parent
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        setUpCharts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProgress.progress=0.0
        fftFeature = node.getFeatureOfType(BlueSTSDKFeatureFFTAmplitude.self) as? BlueSTSDKFeatureFFTAmplitude
        fftFeature?.add(self)
        _ = fftFeature?.enableNotification()
        
        timeDomainFeature = node.getFeatureOfType(BlueSTSDKFeatureMotorTimeParameters.self) as? BlueSTSDKFeatureMotorTimeParameters
        if let feature = timeDomainFeature{
            feature.add(self)
            _ = feature.enableNotification()
        }
        
        settingsButton.isHidden = (node.type == .sensor_Tile_Box)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fftFeature?.remove(self)
        _ = fftFeature?.disableNotification()
        
        if let feature = timeDomainFeature{
            feature.remove(self)
            _ = feature.disableNotification()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dataStatVc = segue.destination as? FFTAmplitudeStatsViewController{
            dataStatVc.maxPoints = maxPoint
            dataStatVc.timeDomainStats = timeDomainStats
            if let popupController = dataStatVc.popoverPresentationController{
                popupController.displayOnView(detailsDialogPlaceHolder);
            }
            return
        }
        if let fftSettings = segue.destination as? FFTSettingsViewController{
            if let console = self.node.debugConsole{
                fftSettings.console = console
            }
        }
    }
    
}


extension FFTAmplitudeViewController : BlueSTSDKFeatureDelegate{
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if (feature.isKind(of: BlueSTSDKFeatureFFTAmplitude.self)){
            didFFTUpdate(sample)
        }else if feature.isKind(of: BlueSTSDKFeatureMotorTimeParameters.self){
            didMotorParametersUpdate(sample)
        }
    }
    
    private func didFFTUpdate(_ sample:BlueSTSDKFeatureSample){
        let isComplete = BlueSTSDKFeatureFFTAmplitude.isComplete(sample)
        let percentage = BlueSTSDKFeatureFFTAmplitude.getDataLoadPercentage(sample)
        if(isComplete){
            let lineConf = LINE_CONFIG
            let nComponents = min(Int(BlueSTSDKFeatureFFTAmplitude.getNComponents(sample)),lineConf.count)
            let freqSteps = BlueSTSDKFeatureFFTAmplitude.getFrequencySteps(sample)
            let fftData = (0..<nComponents).compactMap{ i in
                return BlueSTSDKFeatureFFTAmplitude.getComponent(sample, index: i)
            }
            updateChart(fftData,freqSteps)
            updateStats(fftData,freqSteps)
            updateLog(fftData, freqSteps)
        }else{
            updateProgres(percentage)
        }
    }
    
    private func updateChart(_ fftData:[[Float]],_ freqSteps:Float){
    
        let dataSets:[ILineChartDataSet] = zip(LINE_CONFIG,fftData).compactMap{ line,data in
            return buildDataSet(conf: line, yData: data, deltaX: freqSteps)
        }
       
        DispatchQueue.main.async {
            self.loadProgress.isHidden=true
            self.chart.data = LineChartData(dataSets: dataSets)
        }
    }
    
    private func updateStats(_ fftData:[[Float]],_ freqSteps:Float){
        self.maxPoint = fftData.map{ values in
            let maxIndex = values.indexMax()
            let maxValue = values[maxIndex]
            let maxFreq = Float(maxIndex)*freqSteps
            return FFTPoint(frequency:maxFreq,amplitude:maxValue)
        }
    }
    
    private func buildLogFileName(basePath:URL,sessionPrefix:String)->URL{
        let fileName = String(format: "%@_%@.csv", sessionPrefix,"FFT")
        return URL(fileURLWithPath: fileName, relativeTo: basePath)
    }
    
    private func printHeader(logFile:URL,_ fftData:[[Float]],_ freqSteps:Float){
        guard let out = try? FileHandle(forWritingTo: logFile) else {
            return
        }
        
        let nodeName = fftFeature?.parentNode.friendlyName() ?? "Unknown"
        out.writeStr(String(format: "Node :,%@\n",nodeName))
        out.writeStr(String(format: "# Components:,%d\n",fftData.count))
        out.writeStr(String(format: "# Sample:, %d\n",fftData[0].count))
        out.writeStr(String(format: "Frequency Step:, %f\n\n",freqSteps))
        out.writeStr("Frequency, ")
        let frequencyName = ["Amplitude X","Amplitude Y","Amplitude Z"]
        let nComponent = min(frequencyName.count,fftData.count)
        out.writeStr(String(format: "%@", frequencyName[0]))
        for i in 1..<nComponent{
            out.writeStr(String(format: ", %@", frequencyName[i]))
        }
        out.writeStr("\n")
        
        out.closeFile()
    }
    
    private func appendData(logFile:URL,_ fftData:[[Float]],_ freqSteps:Float){
        guard let out = try? FileHandle(forWritingTo: logFile) else {
            return
        }
        out.seekToEndOfFile()
        for freq in 0..<fftData[0].count{
            out.writeStr(String(format: "%f", freqSteps*Float(freq)))
            for component in 0..<fftData.count{
                out.writeStr(String(format: ", %f", fftData[component][freq]))
            }
            out.writeStr("\n")
        }
        out.closeFile()
        
    }
    
    private func updateLog(_ fftData:[[Float]],_ freqSteps:Float){
        let vc = DispatchQueue.main.sync{ self.findDemoViewController() }
        guard let demoVc = vc,
            demoVc.isLogging else{
            return
        }
        let file = buildLogFileName(basePath: BlueSTSDKDemoViewController.logDirectoryPath, sessionPrefix: demoVc.logFilePrefix ?? "")
        if !FileManager.default.fileExists(atPath: file.path){
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
            printHeader(logFile:file,fftData,freqSteps)
        }
        appendData(logFile:file,fftData,freqSteps)
    }
   
    private func buildDataSet(conf:LineConfig, yData:[Float],deltaX:Float) -> ILineChartDataSet{
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
    
    private func updateProgres(_ percentage:UInt8){
        DispatchQueue.main.async {
            self.loadProgress.isHidden=false
            self.loadProgress.progress = Float(percentage)/100.0
        }
    }

    private func didMotorParametersUpdate(_ sample:BlueSTSDKFeatureSample){
        timeDomainStats = TimeDomainStats(
            accPreakX:BlueSTSDKFeatureMotorTimeParameters.getAccPeackX(sample),
            accPreakY:BlueSTSDKFeatureMotorTimeParameters.getAccPeackY(sample),
            accPreakZ:BlueSTSDKFeatureMotorTimeParameters.getAccPeackZ(sample),
            rmsSpeedX:BlueSTSDKFeatureMotorTimeParameters.getRMSSpeedX(sample),
            rmsSpeedY:BlueSTSDKFeatureMotorTimeParameters.getRMSSpeedY(sample),
            rmsSpeedZ:BlueSTSDKFeatureMotorTimeParameters.getRMSSpeedZ(sample))
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
