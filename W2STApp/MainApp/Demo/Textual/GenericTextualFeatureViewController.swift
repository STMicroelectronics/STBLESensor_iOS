//
//  GenericTextualFeatureViewController.swift


import Foundation
import BlueSTSDK;

public class GenericTextualFeatureViewController: BlueMSDemoTabViewController {
    
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    var availableFeatures: [BlueSTSDKFeature] = []

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        availableFeatures = node.getFeatures()

        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BaseSubtitleCell")
        
        tableView.delegate = self
        tableView.dataSource = self
      }
    
    
}

extension GenericTextualFeatureViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availableFeatures.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseSubtitleCell", for: indexPath)
        
        let feature = availableFeatures[indexPath.row]
        cell.textLabel?.text = feature.name
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = GenericTextualFeatureDetailViewController()
        let navController = UINavigationController(rootViewController: controller)
        //controller.appName = availablePnPapps[indexPath.row].name!
        controller.node = node
        controller.selectedFeature = availableFeatures[indexPath.row]
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
}


