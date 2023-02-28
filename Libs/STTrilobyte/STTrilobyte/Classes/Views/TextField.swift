//
//  TextField.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import STTheme

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
            
            titleLabel.textColor = isValid ? currentTheme.color.textDark : currentTheme.color.error
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
        let done: UIBarButtonItem = UIBarButtonItem(title: "done".localized(), style: .done, target: self, action: #selector(didPressDoneButton))

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
        
        delegate = self
        
        font = currentTheme.font.regular.withSize(font?.pointSize ?? 14.0)
        borderStyle = .roundedRect
        textColor = currentTheme.color.textDark
        
        configureTitleLabel()
        configureErrorLabel()
        configureSideView()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        
        isValid = true

        returnKeyType = .done
    }
    
    func configureTitleLabel() {
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.font = currentTheme.font.regular.withSize(16.0)
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
        errorLabel.textColor = currentTheme.color.error
        errorLabel.alpha = 0.0
        errorLabel.numberOfLines = 1
        errorLabel.font = currentTheme.font.regular.withSize(12.0)
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
        
        sideView.backgroundColor = currentTheme.color.error
        NSLayoutConstraint.activate([
            sideView.leftAnchor.constraint(equalTo: leftAnchor),
            sideView.topAnchor.constraint(equalTo: topAnchor),
            sideView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sideView.widthAnchor.constraint(equalToConstant: 4.0)
        ])
    }
}

extension TextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
