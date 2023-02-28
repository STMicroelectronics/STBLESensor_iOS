//
//  DataPlotDetailViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Charts

class DataPlotDetailViewController: UIViewController {
    public struct Data {
        let title: String
        let dataFormat: String
        let samples: [ChartDataEntry]
    }
    
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mDetailsTable: UITableView!
    
    public var bundle: Bundle? = nil
    public var data: Data?=nil;
    private var sortedSamples: [ChartDataEntry] {
        guard let data = data else { return [] }
        return data.samples.sorted(by: { $0.x > $1.x } )
    }
    
    init() {
        super.init(nibName: "DataPlotDetailViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        mTitle.text = data?.title
        mDetailsTable.reloadData()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        mDetailsTable.showsVerticalScrollIndicator = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        /** Used to load .xib view (tableView cell) in Pod File */
        bundle = Bundle(for: self.classForCoder)
        
        mDetailsTable.delegate = self
        mDetailsTable.dataSource = self
        
        let nib = UINib(nibName: "DataPlotDetailCell", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        mDetailsTable.register(nib, forCellReuseIdentifier: "dataplotdetailcell")
    }
    
    @objc
    func cancelTapped(sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
}

extension DataPlotDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Data Detail Sample Cell n\(indexPath) tapped")
    }
    
}

extension DataPlotDetailViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedSamples.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataplotdetailcell", for: indexPath) as! DataPlotDetailCell
        cell.selectionStyle = .none
        
        let entry = sortedSamples[indexPath.row]
        
        cell.timestamp.text = DateFormatter.full.string(from: entry.x.date)
        
        let valueStr = String(format: "%.2f", entry.y)
        let unitStr = String(data?.dataFormat ?? "")
        
        cell.value.text = "\(valueStr) \(unitStr)"
        
        return cell
    }
}
