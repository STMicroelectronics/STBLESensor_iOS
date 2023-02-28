//
//  DashboardDetailViewController.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/10/2020.
//

import UIKit
import AssetTrackingDataModel
import TrackerThresholdUtil

class DashboardDetailViewController: UIViewController {
    private let filterSegmentedControl = UISegmentedControl(items: FilterInterval.allCases.map { $0.title })
    private var currentFilter: FilterInterval = .threeHours
    private let contentSegmentedView = PlainSegmentedView(items: ["TELEMETRY", "LOCATION", "EVENTS"], font: UIFont.systemFont(ofSize: 16), color: .black)
    
    // Containment
    private let contentView = UIView()
    private var currentViewController: UIViewController?
    
    private lazy var locationViewController = DashboardLocationViewController(deviceManager: deviceManager, deviceId: deviceId)
    private lazy var sensorsViewController: TrackerSensorSampleViewController = {
        let bundle = TrackerThresholdUtilBundle.bundle()
        let storyBoard = UIStoryboard(name: "ShowData", bundle: bundle)
        return storyBoard.instantiateViewController(withIdentifier: "SmarTagSensorDataViewController") as! TrackerSensorSampleViewController
    }()
    private lazy var eventsViewController: TrackerEventSampleViewController = {
        let bundle = TrackerThresholdUtilBundle.bundle()
        let storyBoard = UIStoryboard(name: "ShowData", bundle: bundle)
        return storyBoard.instantiateViewController(withIdentifier: "SmarTagEventDataViewController") as! TrackerEventSampleViewController
    }()
    
    private let deviceManager: DeviceManager
    private let deviceId: String
    
    init(deviceManager: DeviceManager, deviceId: String) {
        self.deviceManager = deviceManager
        self.deviceId = deviceId
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
        
        let bundle = TrackerThresholdUtilBundle.bundle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"

        view.backgroundColor = .white
        configureViews()

        eventsViewController.sampleProvider = DeviceDataSampleProvider(sampleHandler: loadEvents, rangeHandler: getRange)
        sensorsViewController.sampleProvider = DeviceDataSampleProvider(sampleHandler: loadSensors, rangeHandler: getRange)

        switchContentTo(sensorsViewController)
        filterWith(currentFilter)
    }
}

private extension DashboardDetailViewController {
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
    
    func switchContentTo(_ viewController: UIViewController) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
        
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

    func getRange(completion: @escaping ClosedRangeHandler) {
        completion(currentFilter.start.timestampDouble...currentFilter.end.timestampDouble)
    }
    
    func loadEvents(completion: @escaping SampleHandler) {
        deviceManager.loadData(deviceId: deviceId,
                               from: currentFilter.start,
                               to: currentFilter.end,
                               resultType: EventDataSample.self) { [weak self] result in
            
            guard case .success(let responseItems) = result else {
                completion([])
                return
            }
            
            let dataSamples = responseItems
                .flatMap { $0.event }
                .map { DataSample.event(data: $0) }
            
            completion(dataSamples)
        }
    }
    
    func loadSensors(completion: @escaping SampleHandler) {
        deviceManager.loadData(deviceId: deviceId,
                               from: currentFilter.start,
                               to: currentFilter.end,
                               resultType: SensorDataSample.self) { [weak self] result in
            
            guard case .success(let responseItems) = result else {
                completion([])
                return
            }
            
            let dataSamples = responseItems
                .flatMap { $0.sensor }
                .map { DataSample.sensor(data: $0) }
            
            completion(dataSamples)
        }
    }
}

// MARK: LineSegmentedControlDelegate
extension DashboardDetailViewController: LineSegmentedControlDelegate {
    func lineSegmentedControlDidSelect(index: Int) {
        switch index {
        case 0:
            switchContentTo(sensorsViewController)
        case 1:
            switchContentTo(locationViewController)
        case 2:
            switchContentTo(eventsViewController)
        default:
            break
        }
    }
}

// MARK: UISegmentedControl
extension DashboardDetailViewController {
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
        eventsViewController.loadData()
        sensorsViewController.loadData()
    }
}
