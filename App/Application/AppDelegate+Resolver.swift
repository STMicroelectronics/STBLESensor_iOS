//
//  AppDelegate+Resolver.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore
import STBlueSDK

extension AppDelegate {

    func configureResolver() {
        let sessionService = SessionServiceCore()
        
        Resolver.shared.register(type: FavoritesService.self, instance: FavoritesServiceCore())
        Resolver.shared.register(type: CatalogService.self, instance: CatalogServiceCore())
        Resolver.shared.register(type: SessionService.self, instance: sessionService)
        Resolver.shared.register(type: NetworkSession.self, instance: sessionService)
        Resolver.shared.register(type: Network.self, instance: NetworkService(timeout: 10.0, pinnedCertificates: []))

    }

}
