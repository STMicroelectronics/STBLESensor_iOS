//
//  PianoViewController.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI
import STBlueSDK

final class PianoViewController: DemoNodeNoViewController<PianoDelegate> {
    
    override func configure() {
        super.configure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Demo.piano.title
        
        presenter.load()
    }
    
    override func configureView() {
        super.configureView()
        
        let swiftUIView = PianoView(presenter: self.presenter as! PianoPresenter)

        // Define a hosting UIKit view controller that manages a SwiftUI view hierarchy.
        let host = UIHostingController(rootView: swiftUIView)
        let hostView = host.view!

        // Add the SwiftUI view to the UIKit view
        view.addSubview(hostView, constraints: [
                    equal(\.leadingAnchor, constant: 0),
                    equal(\.trailingAnchor, constant: 0),
                    equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
                    equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
                ])
        
    }
}
