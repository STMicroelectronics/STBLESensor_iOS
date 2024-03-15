//
//  TextField.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

class TextField: UITextField {
    
    var validators: [Validator<String>] = [Validator<String>]()
    
    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    public var errorText: String? {
        didSet {
            errorLabel.text = errorText
        }
    }
    
    private lazy var titleLabel: UILabel = UILabel()
    private lazy var errorLabel: UILabel = UILabel()
    private lazy var sideView: UIView = UIView()

    private var completionHandler: ((String?) -> Void)?
    
    public var isValid: Bool = true {
        didSet {
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else { return }
                
                let alpha: CGFloat = strongSelf.isValid ? 0.0 : 1.0
                
                strongSelf.errorLabel.alpha = alpha
                strongSelf.sideView.alpha = alpha
            }
            
            if isValid {
                TextLayout.title2.apply(to: titleLabel)
            } else {
                TextLayout.accent.apply(to: titleLabel)
            }
        }
    }
    
    // MARK: View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var frame = sideView.bounds
        frame.size.width = 10.0
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 4.0)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        sideView.layer.mask = shapeLayer
    }

    func configure(completionHandler: @escaping (String?) -> Void) {
        self.completionHandler = completionHandler
    }

    func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDoneButton))
        done.tintColor = ColorLayout.primary.auto

        let items: [UIBarButtonItem] = [flexSpace, done]

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc
    func didPressDoneButton() {
        if let completitionHandler = completionHandler {
            completitionHandler(text)
        }

        resignFirstResponder()
    }
    
}

private extension TextField {
    
    func configureView() {
        
        self.layer.borderColor = ColorLayout.stGray5.light.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.borderColor = ColorLayout.stGray5.light.cgColor
        delegate = self
        
        configureTitleLabel()
        configureErrorLabel()
        configureSideView()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        isValid = true

        returnKeyType = .done
    }
    
    func configureTitleLabel() {
        TextLayout.text.apply(to: titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: -8)
        ])
    }
    
    func configureErrorLabel() {
        TextLayout.accent.apply(to: errorLabel)
        errorLabel.alpha = 0.0
        errorLabel.numberOfLines = 1
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.rightAnchor.constraint(equalTo: rightAnchor),
            errorLabel.leftAnchor.constraint(equalTo: leftAnchor),
            errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: -14.0)
        ])
    }
    
    func configureSideView() {
        sideView.alpha = 0.0
        sideView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sideView)
        
        sideView.backgroundColor = ColorLayout.redAccent.auto
        NSLayoutConstraint.activate([
            sideView.leftAnchor.constraint(equalTo: leftAnchor),
            sideView.topAnchor.constraint(equalTo: topAnchor),
            sideView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sideView.widthAnchor.constraint(equalToConstant: 4.0)
        ])
    }
}

extension TextField {
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !isValid {
            isValid = true
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didPressDoneButton()
        return true
    }
}

extension TextField: Validable {
    
    func validate() -> Result {
        
        for validator in validators {
            let result = validator.validate(object: text)
            
            switch result {
            case .success:
                break
            case .failure(let message):
                errorText = message
                isValid = false
                return result
            }
        }
        
        isValid = true
        return Result.success
    }
    
}
