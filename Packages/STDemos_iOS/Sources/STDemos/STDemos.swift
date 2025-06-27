//
//  STDemos.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI
import UIKit

public struct STDemos {
    public static var bundle: Bundle = Bundle.module
}

extension UIViewController {
    public func presentSwiftUIView<Content: View>(_ swiftUIView: Content) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add the hosting controller's view as a subview
        addChild(hostingController)
        view.addSubview(hostingController.view)
               
        // Set the hosting controller's frame to fill the parent view
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               
        // Notify the hosting controller
        hostingController.didMove(toParent: self)
    }
}
