//
//  FlowItem.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 26/03/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

protocol FlowItemViewDelegate: class {
    func didPressFlowItem(view: FlowItemView)
    func didPressSettingsButton(flowItem: FlowItem)
    func didPressDeleteButton(flowItem: FlowItem)
}

class FlowItemView: UIView {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomView: UIView!
    
    let placeHolderButton = UIButton(type: .custom)
    var borderView: UIView?
    
    var items: [FlowItem] = [FlowItem]()

    var isSwipeEnabled = false
    
    weak var delegate: FlowItemViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    func configure(title: String, placeholder: String, items: [FlowItem], showLine: Bool = true) {
        titleLabel.text = title
        placeHolderButton.setTitle(placeholder, for: .normal)
        
        self.items = items
        
        stackView.removeAllArrangedSubviews()
                    
        if items.isEmpty {
            stackView.addArrangedSubview(placeHolderButton)
        }
        
        items.forEach { item in
            let itemView: FlowItemRow = FlowItemRow.createFromNib()
            itemView.configure(with: item)
            itemView.delegate = self

            if isSwipeEnabled {
                stackView.addArrangedSubview(itemView.addSwipe(with: [.delete]) { [weak self] action in
                    switch action {
                    case .delete:
                        guard let self = self else { return }
                        self.delegate?.didPressDeleteButton(flowItem: item)
                    case .edit:
                        print("edit: \(item.identifier)")
                    }
                })
            } else {
                stackView.addArrangedSubview(itemView)
            }
        }
        
        bottomView.isHidden = !showLine
    }
}

private extension FlowItemView {
    func configureView() {
        
        headerView.backgroundColor = currentTheme.color.cardPrimary
        
        checkImage.image = UIImage.named("img_done_circle")?.withRenderingMode(.alwaysTemplate)
        checkImage.tintColor = currentTheme.color.textDark
        checkImage.isHidden = true
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        
        placeHolderButton.titleLabel?.font = currentTheme.font.regular.withSize(16.0)
        placeHolderButton.setTitleColor(currentTheme.color.text, for: .normal)
        placeHolderButton.contentHorizontalAlignment = .left
        placeHolderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        placeHolderButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        placeHolderButton.addTarget(self, action: #selector(placeHolderButtonPressed(sender:)), for: .touchUpInside)
        placeHolderButton.backgroundColor = currentTheme.color.cardPrimary
        
        borderView = container.applyStyle(.border(insets: .zero, cornerRadius: 2.0, height: 1.0),
                                          fillColor: nil,
                                          strokeColor: currentTheme.color.cardPrimary,
                                          overlay: true)
        
        
        
        headerView.backgroundColor = currentTheme.color.cardSecondary
        checkImage.isHidden = items.isEmpty
        borderView?.layer.borderColor = currentTheme.color.cardSecondary.cgColor
        bottomView.backgroundColor = currentTheme.color.cardSecondary
        
    }
    
    @objc
    func placeHolderButtonPressed(sender: UIButton) {
        guard let delegate = delegate else { return }
        
        delegate.didPressFlowItem(view: self)
    }
}

extension FlowItemView: FlowItemRowDelegate {
    func didPressRowItem(item: FlowItemRow) {
        guard let delegate = delegate else { return }
        
        delegate.didPressFlowItem(view: self)
    }
    
    func didPressSettings(item: FlowItemRow) {
        guard let delegate = delegate, let flowItem = item.flowItem else { return }
        
        delegate.didPressSettingsButton(flowItem: flowItem)
    }
    
}
