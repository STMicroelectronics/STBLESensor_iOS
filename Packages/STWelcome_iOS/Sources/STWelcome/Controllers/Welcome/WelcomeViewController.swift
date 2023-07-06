//
//  WelcomeViewController.swift
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

public final class WelcomeViewController: WelcomeBaseViewController<WelcomeDelegate, WelcomeView> {

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        title = "Welcome_title"

        presenter.load()
    }

    public override func configureView() {
        super.configureView()
    
        mainView.collectionView?.delegate = self
        mainView.collectionView?.dataSource = self
        mainView.collectionView?.showsHorizontalScrollIndicator = false
        
        mainView.collectionView?.registerNibCell(PageCollectionViewCell.self, bundle: Bundle.module)
        
        mainView.nextButton.addTarget(self, action: #selector(nextButtonTouched(_:)), for: .touchUpInside)
    }

}

private extension WelcomeViewController {
    
    @objc
    func nextButtonTouched(_ sender: Any?)  {
        self.presenter.didTouchNextButton()
    }
    
}

extension WelcomeViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.totalPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.reusableIdentifier, for: indexPath)
        
        guard let cell = cell as? PageCollectionViewCell else { return cell }
        
        let page = presenter.page(at: indexPath.item)
        
        cell.titleLabel.text = page.title
        cell.contentLabel.text = page.content
        cell.imageView.image = page.image
        
        return cell
    }
}

extension WelcomeViewController: UICollectionViewDelegate {
}

extension WelcomeViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}

extension WelcomeViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        presenter.refreshCurrentPageIndex()
    }
}
