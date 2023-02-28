//
//  DashboardLocationViewController.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 20/10/2020.
//

import UIKit
import MapKit
import AssetTrackingDataModel

class DashboardLocationViewController: UIViewController, FilterRefreshable {
    let mapView = MKMapView()
    
    private let deviceManager: DeviceManager
    private let deviceId: String
    private var currentFilter: FilterInterval { didSet { loadData() } }
    
    init(deviceManager: DeviceManager, deviceId: String, filter: FilterInterval = .threeHours) {
        self.deviceManager = deviceManager
        self.deviceId = deviceId
        self.currentFilter = filter
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        mapView.showsCompass = true
        mapView.showsScale = true
        
        loadData()
    }
    
    func loadData() {
        deviceManager.loadData(deviceId: deviceId, from: currentFilter.start, to: currentFilter.end, resultType: Location.self) { [weak self] result in
            guard let self = self else { return }

            guard case .success(let items) = result else { return }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                items.forEach { item in
                    guard case .location(let position) = item else { return }
                    self.setPinUsing(location: position)
                }
                
                self.mapView.fitAll()
            }
        }
    }
    
    // MARK: FilterRefreshable
    func filterChanged(_ filter: FilterInterval) {
        currentFilter = filter
    }
}

private extension DashboardLocationViewController {
    func setupViews() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setPinUsing(location: Location) {
        let locationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = ""
        annotation.subtitle = "Device Location"
        mapView.addAnnotation(annotation)
    }
}

extension MKMapView {
    func fitAll() {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}
