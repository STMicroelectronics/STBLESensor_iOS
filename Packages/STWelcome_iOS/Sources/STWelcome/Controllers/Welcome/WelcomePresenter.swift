//
//  WelcomePresenter.swift
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

public final class WelcomePresenter: BasePresenter<WelcomeViewController, Welcome> {
    
    public var currentPageIndex: Int = 0
    public var totalPages: Int {
        param.pages.count
    }
    
}

// MARK: - WelcomeDelegate
extension WelcomePresenter: WelcomeDelegate {
    
    public func load() {
        view.configureView()
        
        view.mainView.pageControl.pageIndicatorTintColor = ColorLayout.primary.light
        view.mainView.pageControl.currentPageIndicatorTintColor = ColorLayout.primary.dark
        view.mainView.pageControl.numberOfPages = param.pages.count
        
        view.mainView.nextButton.setTitle(param.pages[currentPageIndex].next, for: .normal)
        view.mainView.nextButton.isHidden = param.pages[currentPageIndex].isNextHidden

        if let url = param.licenseUrl {
            let controller = LicensePresenter(param: url).start()
            controller.modalPresentationStyle = .fullScreen

            view.present(controller, animated: false, completion: nil)
        }
    }
    
    public func page(at index: Int) -> WelcomePage {
        param.pages[index]
    }
    
    public func refreshCurrentPageIndex() {
        currentPageIndex = view.mainView.collectionView?.currentPage ?? 0
        
        view.mainView.pageControl.currentPage = currentPageIndex
        view.mainView.nextButton.setTitle(param.pages[currentPageIndex].next, for: .normal)
        view.mainView.nextButton.isHidden = param.pages[currentPageIndex].isNextHidden
    }
    
    public func didTouchNextButton() {
        self.param.callback()
    }

}
