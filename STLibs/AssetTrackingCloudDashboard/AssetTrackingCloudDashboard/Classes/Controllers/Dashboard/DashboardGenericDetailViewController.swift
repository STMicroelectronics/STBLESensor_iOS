//
//  DashboardGenericDetailViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import UIKit
import AssetTrackingDataModel
import TrackerThresholdUtil
import SmarTagLib

public class DashboardGenericDetailViewController: UIViewController {
    
    private let filterSegmentedControl = UISegmentedControl(items: FilterInterval.allCases.map { $0.title })
    private var currentFilter: FilterInterval = .threeHours
    private let contentSegmentedView = PlainSegmentedView(items: ["PLOT", "LOCATION", "LIST"], font: UIFont.systemFont(ofSize: 16), color: .black)
    
    // Containment
    private let contentView = UIView()
    private var currentViewController: UIViewController?
    
    public var genericThresholdsList: [GenericThreshold] = []
    public var genericSamplesList: [GenericSample] = []
    
    private lazy var locationViewController = DashboardLocationViewController(deviceManager: deviceManager, deviceId: deviceId)
    private var plotViewController: DataPlotViewController?
    private var listViewController: DataListViewController?
    
    private let deviceManager: DeviceManager
    private let deviceId: String
    
    public init(deviceManager: DeviceManager, deviceId: String) {
        self.deviceManager = deviceManager
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
        
        let bundle = TrackerThresholdUtilBundle.bundle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Device History"

        view.backgroundColor = .white
        configureViews()

        initializeData()

        plotViewController = DataPlotViewController(genericThresholdsList: genericThresholdsList, genericSamplesList: [])
        plotViewController?.sampleProvider = DeviceGenericSampleProvider(sampleHandler: loadSensors, rangeHandler: getRange)
        listViewController = DataListViewController(genericThresholdsList: genericThresholdsList, genericSamplesList: [])
        listViewController?.sampleProvider = DeviceGenericSampleProvider(sampleHandler: loadSensors, rangeHandler: getRange)
        
        switchContentTo(plotViewController)
        filterWith(currentFilter)
    }

}

private extension DashboardGenericDetailViewController {
    func configureViews() {
        configureSegmentedController()
        contentSegmentedView.delegate = self
        
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentSegmentedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegmentedControl)
        view.addSubview(contentView)
        view.addSubview(contentSegmentedView)
        
        NSLayoutConstraint.activate([
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            contentSegmentedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentSegmentedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentSegmentedView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 12),
            
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentSegmentedView.bottomAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func switchContentTo(_ viewController: UIViewController?) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
        guard let viewController = viewController else { return }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        currentViewController = viewController
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func initializeData(){
        let fw = getCurrentFw()
        guard let currentFw = fw else { return }
        let currentSamples = loadSensors
        genericThresholdsList = createGenericThresholdsList(fw: currentFw)
    }
    
    private func getCurrentFw() -> Nfc2Firmware? {
        guard let nfcCatalog = Nfc2CatalogService().currentCatalog() else { return nil }
        let boardId = 0x01
        let fwId = 0x01
        guard let currentFw = findCurrentFwFromCatalog(nfcCatalog, devId: Int(boardId), fwId: Int(fwId)) else { return nil }
        return currentFw
    }
    
    public func findCurrentFwFromCatalog(_ catalog: Nfc2Catalog, devId: Int, fwId: Int) -> Nfc2Firmware? {
        var currentFw: Nfc2Firmware? = nil
        catalog.nfcV2firmwares.forEach { fw in
            let catalogDevId = UInt32(fw.nfcDevID.dropFirst(2), radix: 16) ?? 0
            let catalogFwId = UInt32(fw.nfcFwID.dropFirst(2), radix: 16) ?? 0
            if(catalogDevId == devId && catalogFwId == fwId){
                currentFw = fw
            }
        }
        return currentFw
    }
    
    public func createGenericThresholdsList(fw: Nfc2Firmware) -> [GenericThreshold] {
        var thresholdsV2: [GenericThreshold] = []
        fw.virtualSensors.forEach { vs in
            if(vs.plottable){
                thresholdsV2.append(
                    GenericThreshold(
                        id: vs.id,
                        name: vs.displayName,
                        type: vs.type,
                        sensorName: vs.displayName,
                        minValue: vs.threshold.min ?? 0.0,
                        maxValue: vs.threshold.max ?? 0.0,
                        scaleFactor: vs.threshold.scaleFactor,
                        negativeOffset: vs.threshold.offset,
                        unit: vs.threshold.unit ?? "")
                )
            }
        }
        return thresholdsV2
    }

    func getRange(completion: @escaping ClosedRangeHandler) {
        completion(currentFilter.start.timestampDouble...currentFilter.end.timestampDouble)
    }
    
    func loadSensors(completion: @escaping GenericSampleHandler) {
        deviceManager.loadGenericData(deviceId: deviceId,
                               from: currentFilter.start,
                               to: currentFilter.end,
                               resultType: GenericSample.self) { [weak self] result in
            
            guard case .success(let responseItems) = result else {
                completion([])
                return
            }
            
            let dataSamples = responseItems
                .flatMap { $0.generic }
                .map { GenericSample(id: $0.id, type: $0.type, date: $0.date, value: $0.value) }
            
            completion(dataSamples)
        }
    }
}

// MARK: LineSegmentedControlDelegate
extension DashboardGenericDetailViewController: LineSegmentedControlDelegate {
    func lineSegmentedControlDidSelect(index: Int) {
        switch index {
        case 0:
            switchContentTo(plotViewController)
        case 1:
            switchContentTo(locationViewController)
        case 2:
            switchContentTo(listViewController)
        default:
            break
        }
    }
}

// MARK: UISegmentedControl
extension DashboardGenericDetailViewController {
    func configureSegmentedController() {
        filterSegmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        filterSegmentedControl.selectedSegmentIndex = 0 // keep in sync with currentFilter
    }
    
    @objc
    func segmentAction(_ segmentedControl: UISegmentedControl) {
        filterWith(FilterInterval(rawValue: segmentedControl.selectedSegmentIndex) ?? .threeHours)
    }
    
    func filterWith(_ newFilter: FilterInterval) {
        currentFilter = newFilter
        locationViewController.filterChanged(newFilter)
        plotViewController?.loadData()
        listViewController?.loadData()
    }
}
