//
//  UIView+Swipe.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 02/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

typealias SwipeCompletion = ((ViewAction) -> Void)?

enum ViewAction {
    case delete
    case edit
}

enum AssociatedKeys {
    static var completion: UInt8 = 0
    static var actions: UInt8 = 1
}

extension UIView {
    
    private(set) var completion: SwipeCompletion {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.completion) as? SwipeCompletion else {
                return nil
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.completion, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var actions: [ViewAction]? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.actions) as? [ViewAction] else {
                return nil
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.actions, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addSwipe(with actions: [ViewAction], completion: ((ViewAction) -> Void)?) -> UIView {
        
        self.actions = actions
        self.completion = completion
        
        isMultipleTouchEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsView = self.buttonsView(with: actions)
        
        containerView.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([ buttonsView.topAnchor.constraint(equalTo: containerView.topAnchor),
                                      buttonsView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                                      buttonsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        containerView.addSubview(self)
        NSLayoutConstraint.activate([ self.topAnchor.constraint(equalTo: containerView.topAnchor),
                                      self.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                                      self.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                                      self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        leftSwipeGesture.direction = .left
        self.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        rightSwipeGesture.direction = .right
        self.addGestureRecognizer(rightSwipeGesture)

        return containerView
    }
    
}

private extension UIView {
    
    @objc
    func deleteButtonPressed(_ sender: UIView?) {
        animate(self)
        
        guard let completion = completion, let view = sender, let stackView = view.superview as? UIStackView  else { return }
        
        guard let index = stackView.arrangedSubviews.firstIndex(of: view),
            let unwrappedActions = actions else { return }
        
        completion(unwrappedActions[index])
    }
    
    @objc
    func swipe(_ sender: UIGestureRecognizer) {
        
        guard let view = sender.view else { return }
        
        animate(view)
    }
    
    func animate(_ view: UIView) {
        guard let superview = view.superview, let actions = actions else { return }
        
        for contraint in superview.constraints {
            if contraint.firstAnchor === view.leftAnchor {
                contraint.constant = contraint.constant == 0 ? contraint.constant - superview.frame.height * CGFloat(actions.count) : 0.0
            }
            
            if contraint.firstAnchor === view.rightAnchor {
                contraint.constant = contraint.constant == 0 ? contraint.constant - superview.frame.height * CGFloat(actions.count)  : 0.0
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            superview.layoutIfNeeded()
        }
    }
    
    func buttonsView(with actions: [ViewAction]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal

        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for action in actions {
            stackView.addArrangedSubview(button(with: action))
        }
        
        return stackView
    }
    
    func button(with action: ViewAction) -> UIButton {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.backgroundColor = self.backgroundColor(with: action)
        button.setImage(self.image(with: action), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([ button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1.0) ])
        
        return button
    }
    
    func backgroundColor(with action: ViewAction) -> UIColor {
        switch action {
        case .delete:
            return .red
        case .edit:
            return .gray
        }
    }
    
    func image(with action: ViewAction) -> UIImage? {
        switch action {
        case .delete:
            return UIImage.named("img_delete")?.withRenderingMode(.alwaysTemplate)
        case .edit:
            return UIImage.named("img_edit")?.withRenderingMode(.alwaysTemplate)
        }
    }
}
