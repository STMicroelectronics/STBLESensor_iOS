//
//  TabBarView.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public enum TabBarSide {
    case first
    case second
    case third
    case fourth
}

public class TabBarView: UIView {

    let stackView = UIStackView()
    public let actionButton = UIButton(type: .custom)
    public var showArcActionButton: Bool = true
    public var showFourthTab: Bool = true

    let firstStackView = UIStackView()
    let secondStackView = UIStackView()
    let thirdStackView = UIStackView()
    let fourthStackView = UIStackView()

    let stackContainerView = UIView()

    convenience init(with actionIcon: UIImage?) {

        self.init(frame: CGRect.zero)

        clipsToBounds = false
        
        self.showArcActionButton = showArcActionButton
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 60.0

        firstStackView.axis = .horizontal
        secondStackView.axis = .horizontal
        thirdStackView.axis = .horizontal
        fourthStackView.axis = .horizontal

        firstStackView.distribution = .fillEqually
        firstStackView.spacing = 10.0
        
        let emptyView = UIView()
        emptyView.backgroundColor = .white

        addSubview(emptyView,
                   constraints: [
                    equal(\.bottomAnchor),
                    equal(\.leadingAnchor),
                    equal(\.trailingAnchor),
                    equalDimension(\.heightAnchor, to: 50.0)
                   ])

        stackContainerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()

//        stackContainerView.backgroundColor = .white

        addSubview(stackContainerView,
                   constraints: [
                    equal(\.bottomAnchor),
                    equal(\.leadingAnchor),
                    equal(\.trailingAnchor),
                    equalDimension(\.heightAnchor, to: 50.0)
                   ])

        activate(constraints: [
            equalDimension(\.heightAnchor, to: 75.0)
        ])

        stackView.addArrangedSubview(firstStackView)
        stackView.addArrangedSubview(secondStackView)
        stackView.removeArrangedSubview(thirdStackView)
        stackView.removeArrangedSubview(fourthStackView)
        
        actionButton.tintColor = ColorLayout.primary.auto
        actionButton.setImage(ImageLayout.Common.refresh?.template, for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 25.0
        actionButton.backgroundColor = ColorLayout.secondary.auto
        addSubview(actionButton)

        addSubview(actionButton,
                   constraints: [
                    equal(\.centerXAnchor),
                    equal(\.topAnchor),
                    equalDimension(\.widthAnchor, to: 50.0),
                    equalDimension(\.heightAnchor, to: 50.0)
                   ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: stackContainerView.frame.width / 2.0 - 30.0, y: 0.0))
        
        var arcRadius = 30.0
        if !showArcActionButton {
            arcRadius = 0.0
            stackView.addArrangedSubview(thirdStackView)
            if showFourthTab{
                stackView.addArrangedSubview(fourthStackView)
            }
            actionButton.removeFromSuperview()
            willRemoveSubview(actionButton)
        }
        
        path.addArc(withCenter: CGPoint(x: stackContainerView.frame.width / 2.0, y: 0.0),
                    radius: arcRadius,
                    startAngle: CGFloat(Double.pi),
                    endAngle: 0.0,
                    clockwise: false)
        path.addLine(to: CGPoint(x: stackContainerView.frame.width, y: 0.0))
        path.addLine(to: CGPoint(x: stackContainerView.frame.width, y: frame.height + 100.0))
        path.addLine(to: CGPoint(x: .zero, y: frame.height + 100.0))
        path.close()

        let shapeLayer = CAShapeLayer()

        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = ColorLayout.primary.auto.cgColor
        shapeLayer.fillColor = ColorLayout.primary.auto.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.position = CGPoint(x: 0, y: 0)

        stackContainerView.layer.insertSublayer(shapeLayer, at: 0)
    }
}

public extension TabBarView {

    func removeAllTabs() {
        for view in firstStackView.arrangedSubviews {
            view.removeFromSuperview()
            firstStackView.removeArrangedSubview(view)
        }

        for view in secondStackView.arrangedSubviews {
            view.removeFromSuperview()
            secondStackView.removeArrangedSubview(view)
        }

        for view in thirdStackView.arrangedSubviews {
            view.removeFromSuperview()
            thirdStackView.removeArrangedSubview(view)
        }
        
        for view in fourthStackView.arrangedSubviews {
            view.removeFromSuperview()
            fourthStackView.removeArrangedSubview(view)
        }
    }

    func add(_ item: TabBarItem, side: TabBarSide) {
        if side == .first {
            firstStackView.addArrangedSubview(item)
        } else if side == .second {
            secondStackView.addArrangedSubview(item)
        } else if side == .third {
            thirdStackView.addArrangedSubview(item)
        } else {
            fourthStackView.addArrangedSubview(item)
        }
    }

    func setMainAction(_ callback: @escaping UIControl.UIControlTargetClosure) {
        actionButton.addAction(for: .touchUpInside,
                               closure: callback)
    }
}
