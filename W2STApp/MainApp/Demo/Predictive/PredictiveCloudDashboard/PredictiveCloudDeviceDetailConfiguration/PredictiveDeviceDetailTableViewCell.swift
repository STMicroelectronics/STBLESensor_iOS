//
//  PredictiveDeviceDetailTableViewCell.swift
//  W2STApp

import Foundation

class PredictiveDeviceDetailTableViewCell: UITableViewCell {
    let settingImageView = UIImageView()
    let settingNameLabel = UILabel()
    let settingDescriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        addSubview(settingImageView)
        addSubview(settingNameLabel)
        addSubview(settingDescriptionLabel)
        settingImageView.translatesAutoresizingMaskIntoConstraints = false
        settingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        settingDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        settingNameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        settingDescriptionLabel.font = UIFont.systemFont(ofSize: 15)
        settingDescriptionLabel.textColor = .gray
        
        settingImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            settingImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            settingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingImageView.heightAnchor.constraint(equalToConstant: 32),
            settingImageView.widthAnchor.constraint(equalToConstant: 32),
            
            settingNameLabel.leadingAnchor.constraint(equalTo: settingImageView.trailingAnchor, constant: 16),
            settingNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            settingNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            settingDescriptionLabel.leadingAnchor.constraint(equalTo: settingNameLabel.leadingAnchor),
            settingDescriptionLabel.trailingAnchor.constraint(equalTo: settingNameLabel.trailingAnchor),
            settingDescriptionLabel.topAnchor.constraint(equalTo: settingNameLabel.bottomAnchor, constant: 4),
            settingDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }


    func configure(settingImage: String, settingName: String, settingDescription: String) {
        self.settingImageView.image = UIImage(named: settingImage)
        self.settingNameLabel.text = settingName
        self.settingDescriptionLabel.text = settingDescription
        self.settingDescriptionLabel.numberOfLines = 0

        self.accessoryType = .disclosureIndicator
    }
}
