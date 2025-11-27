//
//  DivisorViewModel.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class DivisorView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let emptyView1 = UIView()
        emptyView1.setDimensionContraints(height: 4.0)
        
        let divisor = UIView()
        divisor.setDimensionContraints(height: 1.0)
        divisor.backgroundColor = .systemGray5
        
        let emptyView2 = UIView()
        emptyView1.setDimensionContraints(height: 4.0)
        
        let stackView = UIStackView.getVerticalStackView(withSpacing: 16.0, views: [
            emptyView1,
            divisor,
            emptyView2
        ])
        
        addSubviewAndFit(stackView)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class LineDivisorViewModel: BaseViewModel<CodeValue<Void>, DivisorView> {
    public required init() {
        super.init()
    }
}
