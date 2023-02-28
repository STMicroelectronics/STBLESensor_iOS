//
//  PredictiveDeviceTableViewCell.swift
//  W2STApp

import Foundation

class PredictiveDeviceTableViewCell: UITableViewCell {
    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let idLabel = UILabel()
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
        addSubview(idLabel)
        addSubview(actionLabel)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        idLabel.font = UIFont.systemFont(ofSize: 15)
        actionLabel.font = UIFont.systemFont(ofSize: 13)
        idLabel.textColor = .gray
        
        iconImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            actionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            actionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            actionLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 12),
            actionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    

    func configure(name: String, id: String, nodeID: String) {
        self.nameLabel.text = name
        self.idLabel.text = id
        if(nodeID == id){
            self.iconImageView.image = UIImage(named: "radioButton_on")
            self.actionLabel.text = "Settings"
        }else{
            self.iconImageView.image = UIImage(named: "radioButton_off")
            self.isUserInteractionEnabled = false
            self.actionLabel.text = ""
        }
        self.accessoryType = .disclosureIndicator
    }
}
