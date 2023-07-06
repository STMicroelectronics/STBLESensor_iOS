//
//  WelcomeView.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public final class WelcomeView: UIView {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var collectionView: UICollectionView?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        Buttonlayout.standard.apply(to: nextButton)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView?.isPagingEnabled = true

        guard let collectionView = self.collectionView else {
            return
        }
        
        topView.addSubview(collectionView, constraints: UIView.fitToSuperViewConstraints)
    }

}
