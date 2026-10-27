//
//  PlotView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 13/10/2026.
//

import SwiftUI
import DGCharts


extension LineChartView {
    func setUpCharts() {
        self.rightAxis.enabled = false
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        self.xAxis.drawLabelsEnabled = false
        
        self.leftAxis.drawZeroLineEnabled = true
        self.rightAxis.drawZeroLineEnabled = true
         
        self.dragEnabled = false
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        
        self.chartDescription.enabled=false
        self.isMultipleTouchEnabled=false
        self.noDataText = "Select Feature"
        
        //self.legend.enabled = false
        let legend = self.legend
        legend.drawInside = false
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .bottom
    }
}

struct PlotView : UIViewRepresentable {
    
    let dataSets: [LineChartDataSet]
    
    func makeUIView(context: Context) -> LineChartView {
        let lineView = LineChartView()
        lineView.setUpCharts()
        return lineView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.noDataText = "No Data"
        uiView.data = LineChartData(dataSets: dataSets)
        uiView.notifyDataSetChanged()
        uiView.leftAxis.forceLabelsEnabled = true
    }
    
}
