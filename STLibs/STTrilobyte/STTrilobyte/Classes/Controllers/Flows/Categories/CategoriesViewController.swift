//
//  FlowsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

private struct FlowCategory {
    let name: String
    let items: [Flow]
}

class CategoriesViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var categories: [FlowCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "navigation_title_flows".localized()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClassCell(CategoriesCell.self)
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        addFooterView()

        getCategories()
    }
}

private extension CategoriesViewController {
    func getCategories() {
        let storedFlows = PersistanceService.shared.getAllPreloadedFlows()
        categories = Dictionary(grouping: storedFlows, by: { $0.category ?? "" })
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
            .map { FlowCategory(name: $0.key, items: $0.value) }
    }
    
    func addFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48))
        footerView.backgroundColor = .clear
        
        let expertButton = UIButton(type: .system)
        expertButton.translatesAutoresizingMaskIntoConstraints = false
        expertButton.setTitle("expert_view".localized().uppercased(), for: .normal)
        expertButton.titleLabel?.font = currentTheme.font.bold.withSize(13.0)
        expertButton.contentHorizontalAlignment = .right
        expertButton.addTarget(self, action: #selector(expertButtonPressed), for: .touchUpInside)
        
        footerView.addSubview(expertButton)
        tableView.tableFooterView = footerView
        
        expertButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        expertButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 24.0).isActive = true
        expertButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -24.0).isActive = true
    }
    
    @objc
    func expertButtonPressed(_ sender: UIButton) {
        let controller: ExpertViewController = ExpertViewController.makeViewControllerFromNib()
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: FlowsViewController = FlowsViewController.makeViewControllerFromNib()
        vc.flows = categories[indexPath.row].items
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesCell.reusableIdentifier(), for: indexPath)
        
        
        if let cell = cell as? CategoriesCell,
           let flow = categories[indexPath.row].items.first {
            cell.configure(with: flow)
        }
        
        return cell
    }
}
