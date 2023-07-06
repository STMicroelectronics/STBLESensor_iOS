//
//  UserProfilingPresenter.swift
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

public final class UserProfilingPresenter: BasePresenter<UserProfilingViewController, Profile> {
    
}

private extension UserProfilingPresenter {
    func configureOptions(with step: Step) {
        for option in step.options {
            
            guard let optionView: OptionView = OptionView.make(with: .module) as? OptionView else { continue }
            
            optionView.titleLabel.text = option.title
            optionView.subtitleLabel.text = option.subtitle
            optionView.imageView.isHidden = option.image == nil
            optionView.imageContainerView.isHidden = option.image == nil
            
            optionView.imageView.image = option.image
            
            Buttonlayout.checkLayout(checkedImage: option.checkedImage,
                                     uncheckedImage: option.uncheckedImage)
            .apply(to: optionView.checkButton)
            
            optionView.checkButton.addAction(for: .touchUpInside) { [weak self] _ in
                
                for current in step.options {
                    current.isSelected = false
                }
                
                option.isSelected = true
                
                self?.refreshUI(with: step)
            }
            
            view.mainView.optionsStackView.addArrangedSubview(optionView)
        }
    }
    
    func refreshUI(with step: Step) {
        for (index, optionView) in view.mainView.optionsStackView.arrangedSubviews.enumerated() {
            guard let optionView = optionView as? OptionView else { return }
            let currentOption = step.options[index]
            optionView.checkButton.isSelected = currentOption.isSelected
            
            if currentOption.isSelected {
                view.mainView.contentLabel.text = currentOption.content
            }
        }
    }
}

// MARK: - AppTypeDelegate
extension UserProfilingPresenter: UserProfilingDelegate {
    
    public func load() {
        view.configureView()
        
        guard let controllers = view.navigationController?.viewControllers else { return }
        
        let filteredControllers = controllers.filter({ view in
            return type(of: view) == UserProfilingViewController.self
        })
        
        let currentStep = param.steps[filteredControllers.count - 1]
        
        view.title = currentStep.navigationTitle
        view.mainView.title.text = currentStep.title
        view.mainView.titleLabel.text = currentStep.titleLabel
        view.mainView.nextButton.setTitle(currentStep.next, for: .normal)
        
        configureOptions(with: currentStep)
        refreshUI(with: currentStep)
    }
    
    public func didTouchNextButton() {
        
        guard let count = view.navigationController?.viewControllers.count else { return }
        
        if count < param.steps.count {
            view.navigationController?.show(UserProfilingPresenter(param: param).start(), sender: self)
        } else {
            param.callback(param)
        }
    }
}
