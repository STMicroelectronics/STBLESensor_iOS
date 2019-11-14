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
import CorePlot

/// Manage a plot view that show an audio signal
public class W2STAudioPlotViewController: NSObject, CPTPlotDataSource{
    
    private static let PLOT_AUDIO_SCALE_FACTOR = 1.0/32768.0;

    /// plot object
    private let mGraph:CPTXYGraph; //graph where plot the feature
    
    /// color to use to draw the line
    public var lineColor = UIColor.red // TODO update line style
    
    /// line width
    public var lineWidth = CGFloat(2);
    
    /// horizontal size of the plot view, used to subsampling the signal to plot
    private let plotWidth:UInt;
    
    /// buffer where read the data to plot
    private let mAudioData: W2STCircularBuffer;

    private var mNSampleAddFromLastDraw:UInt=0;
    private let mUpdateSubsampling:UInt;

    public var mDataToPlot:[W2STCircularBuffer.ScaleSample];
    
    /// initialize the plot view
    ///
    /// - Parameters:
    ///   - view: view where draw the plot
    ///   - dataBuffer: data to plot
    public init(view:CPTGraphHostingView, reDrawAfterSample:UInt, hasDarkTheme:Bool = false){
        mGraph = CPTXYGraph(frame: view.bounds);
        mUpdateSubsampling = reDrawAfterSample;
        plotWidth = UInt(view.bounds.width);
        mAudioData = W2STCircularBuffer(size:Int(plotWidth),
                scale: W2STCircularBuffer.ScaleSample(W2STAudioPlotViewController.PLOT_AUDIO_SCALE_FACTOR));

        mDataToPlot = Array<W2STCircularBuffer.ScaleSample>(repeating: 0, count: Int(plotWidth))

   //     NSLog("buffer: \(mAudioData.count) win: \(view.bounds.width)")
   //     NSLog("plotWidth: \(plotWidth)")

        super.init();
        view.allowPinchScaling = false;
        view.collapsesLayers=true;
        
        initializeGraphView(hasDarkTheme: hasDarkTheme);
       
        view.hostedGraph = mGraph;
    }
    
    
    /// initialize the plot with the axis and line styles
    private func initializeGraphView(hasDarkTheme:Bool){
        if(hasDarkTheme){
            mGraph.apply(CPTTheme(named:CPTThemeName.plainBlackTheme));
        }else {
            mGraph.apply(CPTTheme(named:CPTThemeName.plainWhiteTheme));
        }
        
        
        let dataSourceLinePlot = CPTScatterPlot();
        dataSourceLinePlot.cachePrecision = .double;
        let lineStyle = CPTMutableLineStyle();
        lineStyle.lineWidth = lineWidth;
        lineStyle.lineColor = CPTColor(cgColor:lineColor.cgColor);
        dataSourceLinePlot.dataLineStyle=lineStyle;
        dataSourceLinePlot.dataSource=self;
        dataSourceLinePlot.showLabels=false;
        dataSourceLinePlot.labelTextStyle=nil;
        
        mGraph.add(dataSourceLinePlot);
        let plotRange = mGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotRange.yRange = CPTPlotRange(location: -1.0, length: 2.0)
        plotRange.xRange = CPTPlotRange(location: 0, length: NSNumber(value:plotWidth))
        
        let axis =
            (mGraph.axisSet as! CPTXYAxisSet);
        axis.isHidden=true;
        axis.xAxis?.labelingPolicy=CPTAxisLabelingPolicy.none;
        axis.yAxis?.labelingPolicy=CPTAxisLabelingPolicy.none;
    }

    
    /// numbner of point to plot
    ///
    /// - Parameter plot: object where plot the point
    /// - Returns: number of point to plot, one for each pixel of the plot
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return plotWidth;
    }

    
    /// get the point coordinate
    ///
    /// - Parameters:
    ///   - plot: object where draw the plot
    ///   - fieldEnum: x or y coordinate
    ///   - idx: point index
    /// - Returns: x or y coordinate for the point at the specific index
    public func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
        let scatterField = CPTScatterPlotField(rawValue: Int(fieldEnum));

        switch (scatterField!){
            case CPTScatterPlotField.Y:
                return Double(mDataToPlot[Int(idx)]);
            case CPTScatterPlotField.X:
                return Double(idx);
        }
    }

    public func appendToPlot(_ value:Int16){
        mAudioData.append(W2STCircularBuffer.Sample(value));
        mNSampleAddFromLastDraw = mNSampleAddFromLastDraw+1;
        if(mNSampleAddFromLastDraw==mUpdateSubsampling){
            mNSampleAddFromLastDraw=0;
           updatePlot();
           
        }
    }
    
    /// force the plot redraw
    private func updatePlot(){
        DispatchQueue.main.async {
            self.mAudioData.dumpTo(&self.mDataToPlot);
            self.mGraph.reloadData();
        }
    }

}
