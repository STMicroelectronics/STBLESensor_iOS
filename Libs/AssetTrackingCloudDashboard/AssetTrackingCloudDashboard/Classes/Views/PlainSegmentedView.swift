//
//  PlainSegmentedView.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 21/10/2020.
//

import UIKit

protocol LineSegmentedControlDelegate: class {
    func lineSegmentedControlDidSelect(index: Int)
}

class PlainSegmentedView: UIView {
    public weak var delegate: LineSegmentedControlDelegate?
    
    private let items: [String]
    private let font: UIFont
    private let color: UIColor
    // UI
    private let segmentedControl: PlainSegmentedControl
    private let segmentIndicator = UIView()
    private var segmentLeadingConstraint: NSLayoutConstraint?
    
    init(items: [String], font: UIFont = UIFont(name: "AvenirNextCondensed-Medium", size: 18)!, color: UIColor = .blue) {
        self.items = items
        self.font = font
        self.color = color
        
        self.segmentedControl = PlainSegmentedControl(items: items)
        super.init(frame: .zero)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        let startingFontSize = font.pointSize
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : font.withSize(startingFontSize + 2), NSAttributedString.Key.foregroundColor: color], for: .selected)
        segmentIndicator.backgroundColor = color
        // layout
        addSubview(segmentedControl)
        addSubview(segmentIndicator)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let segmentConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
        segmentLeadingConstraint = segmentConstraint
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            segmentConstraint,
            segmentIndicator.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1/CGFloat(items.count)),
            segmentIndicator.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            segmentIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            segmentIndicator.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    @objc
    func segmentAction(_ sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        segmentLeadingConstraint?.constant = frame.width / CGFloat(items.count) * CGFloat(selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.segmentIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.segmentIndicator.transform = CGAffineTransform.identity
            }
            self.delegate?.lineSegmentedControlDidSelect(index: selectedSegmentIndex)
        }
    }
}

class PlainSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        // Use a clear image for the background and the dividers
        let tintColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
}

extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.init(data: image.pngData()!)!
    }
}
