//
//  DashboardListTableViewCell.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/10/2020.
//

import Foundation

class DashboardListTableViewCell: UITableViewCell {
    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let actionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(dateLabel)
        addSubview(actionLabel)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        actionLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .gray
        
        iconImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            actionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            actionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            actionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    
    func configure(name: String, date: String, image: String?) {
        self.nameLabel.text = name
        self.dateLabel.text = date
        if let image = image {
            self.iconImageView.image = AssetTrackingCloudBundle.bundleImage(named: image)
        }
        self.actionLabel.text = "SHOW DATA"
    }
}
