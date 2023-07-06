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
    case left
    case right
}

public class TabBarView: UIView {

    let stackView = UIStackView()
    public let actionButton = UIButton(type: .custom)

    let leftStackView = UIStackView()
    let rightStackView = UIStackView()

    let stackContainerView = UIView()

    convenience init(with actionIcon: UIImage?) {

        self.init(frame: CGRect.zero)

        clipsToBounds = false
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 60.0

        leftStackView.axis = .horizontal
        rightStackView.axis = .horizontal

        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 10.0

        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 10.0

        stackContainerView.addSubview(stackView)
        stackView.addFitToSuperviewConstraints()

        stackContainerView.backgroundColor = .white

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

        stackView.addArrangedSubview(leftStackView)
        stackView.addArrangedSubview(rightStackView)

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
        path.addArc(withCenter: CGPoint(x: stackContainerView.frame.width / 2.0,
                                        y: 0.0),
                    radius: 30.0,
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
        for view in leftStackView.arrangedSubviews {
            view.removeFromSuperview()
            leftStackView.removeArrangedSubview(view)
        }

        for view in rightStackView.arrangedSubviews {
            view.removeFromSuperview()
            rightStackView.removeArrangedSubview(view)
        }
    }

    func add(_ item: TabBarItem, side: TabBarSide) {
        if side == .left {
            leftStackView.addArrangedSubview(item)
        } else {
            rightStackView.addArrangedSubview(item)
        }
    }

    func setMainAction(_ callback: @escaping UIControl.UIControlTargetClosure) {
        actionButton.addAction(for: .touchUpInside,
                               closure: callback)
    }
}
