//
//  MoreViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class MoreViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var moreItems = [MoreItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "navigation_title_more".localized()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerXibCell("MoreCell")
        tableView.tableFooterView = UIView()
        
        moreItems.append(MoreItem(imageName: "img_book", name: "technical_documentation".localized(), link: "https://www.st.com/sensortilebox"))
        moreItems.append(MoreItem(imageName: "img_contact_support", name: "help_support".localized(), link: "https://www.st.com/sensortilebox"))
        moreItems.append(MoreItem(imageName: "img_waves", name: "about_trilobyte".localized(), link: "https://www.st.com/sensortilebox"))
        moreItems.append(MoreItem(imageName: "logo_st_small", name: "st_website".localized(), link: "https://www.st.com/content/st_com/en.html"))
    }
}

extension MoreViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
        
        cell.textLabel?.font = currentTheme.font.regular.withSize(16.0)
        cell.textLabel?.text = moreItems[indexPath.row].name
        cell.textLabel?.textColor = currentTheme.color.textDark
        cell.imageView?.image = UIImage.named(moreItems[indexPath.row].imageName)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = currentTheme.color.textDark
        cell.imageView?.contentMode = .center
        return cell
    }
}

extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = moreItems[indexPath.row].link
        
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
