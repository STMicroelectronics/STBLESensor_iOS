//
//  MultiNeuralNetworkViewController.swift
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
import STBlueSDK

final class MultiNeuralNetworkViewController: DemoNodeNoViewController<MultiNeuralNetworkDelegate> {
   
    public var availableAlgos: [AvailableAlgorithm] = []
    public var currentAlgo: AvailableAlgorithm? = nil
    
    var containerCurrentAlgorithmView = UIView()
    let currentAlgorithmView = MultiNeuralNetworkCurrentAlgorithmView()
    
    var containerHumanActivityRecognitionView = UIView()
    let humanActivityRecognitionView = MultiNeuralNetworkSingleView()
    
    var containerAudioClassificationView = UIView()
    let audioClassificationView = MultiNeuralNetworkSingleView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Demo.multiNN.title

        presenter.load()
    }

    override func configureView() {
        super.configureView()
        
        containerCurrentAlgorithmView = currentAlgorithmView.embedInView(with: .standardEmbed)
        containerHumanActivityRecognitionView = humanActivityRecognitionView.embedInView(with: .standardEmbed)
        containerAudioClassificationView = audioClassificationView.embedInView(with: .standardEmbed)
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            containerCurrentAlgorithmView,
            containerHumanActivityRecognitionView,
            containerAudioClassificationView,
        ])
        mainStackView.distribution = .fill
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
        
        containerCurrentAlgorithmView.isHidden = true

        containerHumanActivityRecognitionView.isHidden = false
        containerAudioClassificationView.isHidden = false
        
        humanActivityRecognitionView.title.text = "Human Acrivity Classification"
        humanActivityRecognitionView.state.text = "Running"
        audioClassificationView.title.text = "Audio Scene Classification"
        audioClassificationView.state.text = "Running"
        
        presenter.getAvailableAlgorithms()
        
        currentAlgorithmView.button.onTap { [weak self] _ in
            self?.selectAlgorithm()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerCurrentAlgorithmView.backgroundColor = .white
        containerCurrentAlgorithmView.layer.cornerRadius = 8.0
        containerCurrentAlgorithmView.applyShadow()
        
        containerHumanActivityRecognitionView.backgroundColor = .white
        containerHumanActivityRecognitionView.layer.cornerRadius = 8.0
        containerHumanActivityRecognitionView.applyShadow()
        
        containerAudioClassificationView.backgroundColor = .white
        containerAudioClassificationView.layer.cornerRadius = 8.0
        containerAudioClassificationView.applyShadow()
    }
    
    func selectAlgorithm() {
        var actions: [UIAlertAction] = availableAlgos.map { item in
            UIAlertAction.genericButton(item.name) { [weak self] _ in
                self?.presenter.sendAlgotithmCommand(item)
            }
        }
        actions.append(UIAlertAction.cancelButton { [weak self] _ in
            self?.dismiss(animated: true)
        })
        UIAlertController.presentAlert(from: self, title: "Select Algorithm", actions: actions)
    }

    override func manager(_ manager: BlueManager,
                          didUpdateValueFor node: Node,
                          feature: Feature,
                          sample: AnyFeatureSample?) {

        super.manager(manager, didUpdateValueFor: node, feature: feature, sample: sample)

        DispatchQueue.main.async { [weak self] in
            self?.presenter.updateMultiNNUI(with: sample)
        }
    }
}
