//
//  FlowDetail.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 15/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowDetailControllerDelegate: class {
    
    func didSelect(flow: Flow)

}

class FlowDetailController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var flowTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    weak var delegate: FlowDetailControllerDelegate?
    private var flow: Flow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "flow".localized()
        
        configureView()
        
        //        let functions = PersistanceService.shared.getAllFunctions()
    }
    
    func configure(with flow: Flow) {
        self.flow = flow
    }
    
    // MARK: IBActions
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        guard let delegate = delegate, let flow = flow else { return }
        
        delegate.didSelect(flow: flow)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        guard let flow = flow?.copy() as? Flow else { return }
        let controller: NewFlowViewController = NewFlowViewController.makeViewControllerFromNib()
        controller.configure(with: flow)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

private extension FlowDetailController {
    func configureView() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -24.0)
        
        guard let currentFlow = flow else { return }
        
        titleLabel.text = currentFlow.name
        titleLabel.font = currentTheme.font.bold.withSize(24.0)
        titleLabel.textColor = currentTheme.color.primary
        
        subtitleLabel.text = currentFlow.notes
        subtitleLabel.font = currentTheme.font.regular.withSize(16.0)
        subtitleLabel.textColor = currentTheme.color.text
        
        detailView.applyStyle(.border(insets: .zero, cornerRadius: 5.0, height: 1.0),
                              fillColor: currentTheme.color.cardPrimary,
                              strokeColor: currentTheme.color.cardSecondary,
                              overlay: false)
        detailView.applyShadow()
        detailView.backgroundColor = .clear
        
        flowTitleLabel.text = "flow_overview".localized().uppercased()
        flowTitleLabel.font = currentTheme.font.bold.withSize(16.0)
        flowTitleLabel.textColor = currentTheme.color.textDark
        
        playButton.setTitle("device_upload".localized().uppercased(), for: .normal)
        playButton.setImage(UIImage.named("img_publish"), for: .normal)
        playButton.tintColor = currentTheme.color.secondary

        editButton.setTitle("edit".localized().uppercased(), for: .normal)
        editButton.setImage(UIImage.named("img_edit"), for: .normal)
        editButton.tintColor = currentTheme.color.secondary
        
        let inputFlowContainer: FlowContainerView = FlowContainerView.createFromNib()
        
        var items: [FlowItem] = [FlowItem]()
        items.append(contentsOf: currentFlow.sensors)
        items.append(contentsOf: currentFlow.flows)
        
        inputFlowContainer.configure("Input", with: items, in: .first)
        stackView.addArrangedSubview(inputFlowContainer)

        for function in currentFlow.functions {
            let functionContainer: FlowContainerView = FlowContainerView.createFromNib()
            functionContainer.configure("Function", with: [function], in: .middle)
            stackView.addArrangedSubview(functionContainer)
        }

        let outputFlowContainer: FlowContainerView = FlowContainerView.createFromNib()
        outputFlowContainer.configure("Output", with: currentFlow.outputs, in: .last)
        stackView.addArrangedSubview(outputFlowContainer)
    }
}
