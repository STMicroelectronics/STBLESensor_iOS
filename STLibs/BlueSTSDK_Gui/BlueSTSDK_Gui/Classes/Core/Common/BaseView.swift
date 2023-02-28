//
//  BaseView.swift
//
//  Created by Dimitri Giani on 12/01/21.
//

import UIKit

open class BaseView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    open func configureView() {
        
    }
    
    open func updateUI() {
        
    }
}
