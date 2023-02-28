//
//  LoadingView.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 28/01/21.
//

import UIKit
import STTheme

public class LoadingView: BaseView {
    private let loadingIndicatorView = UIActivityIndicatorView(style: .gray)
    private let loadingLabel = UILabel()
    
    public override func configureView() {
        super.configureView()
        
        loadingIndicatorView.hidesWhenStopped = true
        addSubview(loadingIndicatorView, constraints: [
            equal(\.centerXAnchor),
            equal(\.topAnchor)
        ])
        
        loadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        loadingLabel.textColor = currentTheme.color.secondary
        addSubview(loadingLabel, constraints: [
            equal(\.topAnchor, toView: loadingIndicatorView, withAnchor: \.bottomAnchor, constant: 6),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
    }
    
    public func setVisible(_ visible: Bool, text: String) {
        loadingLabel.text = text
        visible ? loadingIndicatorView.startAnimating() : loadingIndicatorView.stopAnimating()
    }
}
