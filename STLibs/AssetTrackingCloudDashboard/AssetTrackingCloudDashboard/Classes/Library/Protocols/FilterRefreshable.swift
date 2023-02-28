//
//  FilterRefreshable.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/11/2020.
//

import Foundation

protocol FilterRefreshable {
    func filterChanged(_ filter: FilterInterval)
}
