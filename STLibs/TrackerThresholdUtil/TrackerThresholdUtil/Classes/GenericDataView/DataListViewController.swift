//
//  DataListViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Foundation

public struct ThresholdFilterField {
    let id: Int
    let name: String
    var enabled: Bool
}

protocol ThresholdsFilterDelegate: class {
    func filterVCDidFinish(_ controller: DataListFilterView, filtersApplied: [ThresholdFilterField])
}

public class DataListViewController: UIViewController, ThresholdsFilterDelegate {
    public var bundle: Bundle? = nil
    
    public var sampleProvider: GenericSampleProvider?
    private var range: ClosedRange<Double>? = nil
    
    public var genericSamplesList: [GenericSample]
    public var genericThresholdsList: [GenericThreshold]

    var originalDataSamples: [GenericSample] = []
    var filteredDataSamples: [GenericSample] = []
    public var filters: [ThresholdFilterField] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterDataLabel: UILabel!
    
    @IBAction func onFilterBtnClicked(_ sender: UIButton) {
        let vc = DataListFilterView()
        vc.filters = filters
        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
    
    @IBAction func onCancelBtnClicked(_ sender: UIButton) {
        resetDataSamples()
        resetFilters()
        resetFilterLabel()
        reloadData()
    }
    
    public init(genericThresholdsList: [GenericThreshold], genericSamplesList: [GenericSample]) {
        self.genericThresholdsList = genericThresholdsList
        self.genericSamplesList = genericSamplesList
        super.init(nibName: "DataListViewController", bundle: Bundle(for: Self.self))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadData() {
        sampleProvider?.getRange { [weak self] range in
            self?.range = range
            self?.sampleProvider?.getSamples { providerSamples in
                self?.genericSamplesList = providerSamples.genericSamples
                guard let self = self else { return }
                guard self.tableView != nil else { return }
                DispatchQueue.main.async { self.refreshTable() }
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Data"
        
        genericThresholdsList.forEach{ th in
            filters.append(ThresholdFilterField(id: th.id, name: th.name, enabled: false))
        }
        
        originalDataSamples = genericSamplesList
        filteredDataSamples = genericSamplesList
        
        /** Used to load .xib view (tableView cell) in Pod File */
        bundle = Bundle(for: self.classForCoder)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "DataListSampleCell", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        tableView.register(nib, forCellReuseIdentifier: "datalistsamplecell")
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func refreshTable() {
        originalDataSamples = genericSamplesList
        resetDataSamples()
        resetFilters()
        resetFilterLabel()
        reloadData()
    }
}

/// FILTERS
extension DataListViewController {
    func filterVCDidFinish(_ controller: DataListFilterView, filtersApplied: [ThresholdFilterField]) {
        self.filters = filtersApplied
        let virtualSensorsEnabled = filters.filter({ $0.enabled })
        
        if !(virtualSensorsEnabled.isEmpty){
            updateShownDataSamples(virtualSensorsEnabled)
            updateFilterLabel(virtualSensorsEnabled)
            reloadData()
        } else {
            resetDataSamples()
            resetFilters()
            resetFilterLabel()
            reloadData()
        }
    }
    
    private func resetFilters(){
        filters = []
        genericThresholdsList.forEach { th in
            filters.append(ThresholdFilterField(id: th.id, name: th.name, enabled: false))
        }
    }
    
    private func resetDataSamples(){
        filteredDataSamples = originalDataSamples
    }
    
    private func updateShownDataSamples(_ virtualSensorsEnabled: [ThresholdFilterField]){
        var newDataSamples: [GenericSample] = []
        filteredDataSamples = originalDataSamples
        
        filteredDataSamples.forEach{ filteredDS in
            virtualSensorsEnabled.forEach{ virtualSensor in
                if(filteredDS.id == virtualSensor.id){
                    newDataSamples.append(filteredDS)
                }
            }
        }
        
        filteredDataSamples = newDataSamples
    }
    
    private func updateFilterLabel(_ virtualSensorsEnabled: [ThresholdFilterField]){
        var filterStr = ""
        virtualSensorsEnabled.forEach{ virtualSensor in
            filterStr += "\(virtualSensor.name) "
        }
        filterStr = "Filter by: \(filterStr)"
        filterDataLabel.text = filterStr
    }
    
    private func resetFilterLabel(){
        filterDataLabel.text = "Filter by: no filter selected"
    }
}

extension DataListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Data Sample Cell n\(indexPath) tapped")
    }
    
}

extension DataListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSamples.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datalistsamplecell", for: indexPath) as! DataListSampleCell
        cell.selectionStyle = .none
        
        let currentDataSample = filteredDataSamples[indexPath.row]
        let th = findCurrentGenericTh(id: currentDataSample.id)
        guard let currentTh = th else { return cell }
        
        cell.sensorImage.image = setSensorImage(type: currentDataSample.type)
        cell.sensorName.text = currentTh.name
        
        guard let v = currentDataSample.value else { return cell }
        guard let d = currentDataSample.date else { return cell }
        
        let valueStr = String(format: "%.2f", v)
        
        cell.value.text = "\(valueStr) \(currentTh.unit ?? "")"
        cell.timestamp.text = iso8601FormatterTag2Samples.string(from: d)
        
        return cell
    }
    
    func findCurrentGenericTh(id: Int) -> GenericThreshold? {
        var currentTh: GenericThreshold? = nil
        genericThresholdsList.forEach{ th in
            if(th.id == id){
                currentTh = th
            }
        }
        return currentTh
    }
    
}
