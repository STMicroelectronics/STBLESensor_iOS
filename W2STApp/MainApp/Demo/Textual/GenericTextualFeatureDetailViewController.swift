//
//  GenericTextualFeatureDetailViewController.swift
//  W2STApp

import Foundation

import UIKit
import BlueSTSDK_Gui
import BlueSTSDK

class GenericTextualFeatureDetailViewController: UIViewController {

    var mFeatureListener: BlueSTSDKFeatureDelegate?
    
    var node: BlueSTSDKNode?
    var selectedFeature: BlueSTSDKFeature?
    
    private var featureWasEnabled = false
    
    var safeArea: UILayoutGuide!
    var availableFeatures: [BlueSTSDKFeature] = []

    private var mDisplayString:NSMutableAttributedString = NSMutableAttributedString()
    
    /** UI elements */
    private let scrollView = UIScrollView()
    private var mainStack: UIStackView!
    
    private var valueStack: UIStackView!
    private let descriptionLabel = UILabel()
    private let featureNameLabel = UILabel()
    /**private var timestampStack: UIStackView!
    private let labelTimestamp = UILabel()
    private let logTimestamp = UILabel()*/
    private let labelValue = UILabel()
    private let logValue = UILabel()
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startNotification()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        setupUI()
    }
    
    @objc
    private func dismissModal() {
        stopNotification()
        dismiss(animated: true)
    }
    
    func setupUI() {
        
        /**timestampStack = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            labelTimestamp,
            logTimestamp
        ])**/
        
        valueStack = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            labelValue,
            logValue
        ])
        
        mainStack = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            featureNameLabel,
            descriptionLabel,
            //timestampStack,
            valueStack
        ])
        
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.addSubview(mainStack, constraints: [
            equal(\.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(scrollView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        featureNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        featureNameLabel.text = selectedFeature?.name
        featureNameLabel.numberOfLines = 0
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        descriptionLabel.text = "In this section you can see raw data value regarding \(selectedFeature!.name) feature"
        descriptionLabel.numberOfLines = 0
        
        /**labelTimestamp.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        labelTimestamp.text = "Timestamp"
        
        logTimestamp.text = "No data ..."
        logTimestamp.font = UIFont.systemFont(ofSize: 16, weight: .light)
        logTimestamp.numberOfLines = 0*/
        
        labelValue.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        labelValue.text = "• Raw Value •"
        
        logValue.text = "No data ..."
        logValue.font = UIFont.systemFont(ofSize: 16, weight: .light)
        logValue.numberOfLines = 0
    }
    
    public func startNotification(){
        if !(node==nil){
            if !(selectedFeature==nil){
                /**selectedFeature!.addLoggerDelegate(self) --> Logger Delegate */
                selectedFeature!.add(self)
                self.node!.enableNotification(self.selectedFeature!)
                self.node!.read(self.selectedFeature!)
            }
        }
    }
    
    public func stopNotification(){
        if !(node==nil){
            if !(selectedFeature==nil){
                /**selectedFeature!.removeLoggerDelegate(self) --> Logger Delegate */
                selectedFeature!.remove(self)
                self.node!.disableNotification(self.selectedFeature!);
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    @objc func didEnterForeground() {
        if !(node==nil){
            if !(selectedFeature==nil){
                if(node!.isEnableNotification(selectedFeature!)) {
                    featureWasEnabled = true
                    stopNotification()
                }else {
                    featureWasEnabled = false;
                }
            }
        }
    }
        
    @objc func didBecomeActivity() {
        if(featureWasEnabled) {
            startNotification()
        }
    }
    
    
}

/** Logger Delegate
extension GenericTextualFeatureDetailViewController: BlueSTSDKFeatureLogDelegate{
    func feature(_ feature: BlueSTSDKFeature, rawData raw: Data, sample: BlueSTSDKFeatureSample) {
        print("Log Feature: \(feature), rawData: \(raw), sample: \(sample)")
        let message = "Log Feature: \(feature), rawData: \(raw), sample: \(sample)"
        consoleMsg.append(message + "\n")
        DispatchQueue.main.async { [self] in
            self.logTextView.text = consoleMsg
        }
    }
}*/

extension GenericTextualFeatureDetailViewController: BlueSTSDKFeatureDelegate {
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async { [self] in
            self.logValue.text = feature.description()
        }
    }
}


