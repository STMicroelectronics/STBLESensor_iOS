//
//  DataPlotViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Charts
import TrackerThresholdUtil

struct ChartExtreme {
    let min: Double
    let max: Double
}

public class DataPlotViewController: UIViewController {
    public var bundle: Bundle? = nil
    
    public var sampleProvider: GenericSampleProvider?
    private var range: ClosedRange<Double>? = nil
    
    public var genericSamplesList: [GenericSample]
    public var genericThresholdsList: [GenericThreshold]
    
    private var tableData: [DataPlotCell.Data] = []
    private var detailsData: [DataPlotDetailViewController.Data] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    public init(genericThresholdsList: [GenericThreshold], genericSamplesList: [GenericSample]) {
        self.genericThresholdsList = genericThresholdsList
        self.genericSamplesList = genericSamplesList
        super.init(nibName: "DataPlotViewController", bundle: Bundle(for: Self.self))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// create the cell and the details data to display
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { self.refreshTable() }
    }
    
    public func loadData() {
        sampleProvider?.getRange { [weak self] range in
            self?.range = range
            
            self?.sampleProvider?.getSamples { providerSamples in
                self?.genericSamplesList = providerSamples.genericSamples
                DispatchQueue.main.async { self?.refreshTable() }
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Plot"
        tableView.showsVerticalScrollIndicator = false
        
        /** Used to load .xib view (tableView cell) in Pod File */
        bundle = Bundle(for: self.classForCoder)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "DataPlotCell", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        tableView.register(nib, forCellReuseIdentifier: "dataplotcell")
    }
    
    private func createChartDataEntry(sample: GenericSample) -> ChartDataEntry? {
        guard let xValue = sample.date else { return nil }
        guard let yValue = sample.value else { return nil }
        
        return ChartDataEntry(
            x: xValue.timestampDouble,
            y: yValue
        )
    }
    
    private func refreshTable() {
        tableData = []
        detailsData = []
        
        for i in 0..<genericThresholdsList.count {
            let currentThreshold = genericThresholdsList[i]
            
            var name = currentThreshold.name
            var unit = currentThreshold.unit ?? ""
            var displayName = "\(name) (\(unit))"
            var samples = genericSamplesList.filter { sample in sample.id == currentThreshold.id }
            
            var chartDataEntries: [ChartDataEntry] = []
            samples.forEach { sample in
                var dataEntry = createChartDataEntry(sample: sample)
                if(dataEntry != nil){
                    chartDataEntries.append(createChartDataEntry(sample: sample)!)
                }
            }
            
            var minYvalue = currentThreshold.minValue ?? 0.0
            var maxYvalue = currentThreshold.maxValue ?? 0.0
            var plotRange = minYvalue...maxYvalue
            
            if !(samples.isEmpty){
                tableData.append(
                    DataPlotCell.Data(
                        name: displayName,
                        samples: chartDataEntries,
                        plotRange: plotRange,
                        timeRange: range
                    )
                )
                
                detailsData.append(
                    DataPlotDetailViewController.Data(
                        title: displayName,
                        dataFormat: unit ?? "",
                        samples: chartDataEntries
                    )
                )
            }
        }
        
        tableView.reloadData()
    }
    
}

extension DataPlotViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Data Sample Cell n\(indexPath) tapped")
    }
    
}

extension DataPlotViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataplotcell", for: indexPath) as! DataPlotCell
        cell.selectionStyle = .none

        cell.setup(data: tableData[indexPath.row])
        
        let dataDetails = detailsData[indexPath.row]
        cell.onDetailsClick = {
            let vc = DataPlotDetailViewController()
            vc.data = dataDetails
            let navigationController = UINavigationController(rootViewController: vc)
            self.present(navigationController, animated: true)
        }
        
        return cell
    }
    
    func createDataSet(data: [ChartDataEntry]) -> LineChartData {
        let dataSet = LineChartDataSet(entries: data, label: nil)
        
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 5
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 2.0
        dataSet.setColor(UIColor.blue)
        
        return LineChartData(dataSet: dataSet)
    }
    
}
