//
//  DataListFilterView.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class DataListFilterView: UIViewController {
    weak var delegate: ThresholdsFilterDelegate?
    
    var filters: [ThresholdFilterField] = []
    public var bundle: Bundle? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    init() {
        super.init(nibName: "DataListFilterView", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        /** Used to load .xib view (tableView cell) in Pod File */
        bundle = Bundle(for: self.classForCoder)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "FilterCell", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        tableView.register(nib, forCellReuseIdentifier: "filtercell")
    }
    
    @objc
    func doneTapped(sender: UIBarButtonItem){
        delegate?.filterVCDidFinish(self, filtersApplied: filters)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func cancelTapped(sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
}

extension DataListFilterView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FilterCell
        
        if(cell.checkmark.isHidden){
            cell.checkmark.isHidden = false
            filters[indexPath.row].enabled = true
        } else {
            cell.checkmark.isHidden = true
            filters[indexPath.row].enabled = false
        }
    }
    
}

extension DataListFilterView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filtercell", for: indexPath) as! FilterCell
        cell.selectionStyle = .none
        
        let currentVS = filters[indexPath.row]
        
        cell.name.text = currentVS.name
        
        if(currentVS.enabled){
            cell.checkmark.isHidden = false
        }
        
        return cell
    }
}

