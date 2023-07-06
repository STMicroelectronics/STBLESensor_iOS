//
//  TableDirector.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STCore

open class TableDirector: NSObject, UITableViewDataSource, UITableViewDelegate {

    public var isFirstCellLocked: Bool = false

    public var elements: [any CellViewModel] = [any CellViewModel]()

    public var onSelectHandler: ((IndexPath) -> Void)?

    public var onMoveHandler: ((_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void)?

    public private(set) weak var tableView: UITableView?

    public init(with tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }

    public func register(viewModel: any CellViewModel.Type, type: ReusableCellType = .fromNib, bundle: Bundle = STUI.bundle) {
        tableView?.register(viewModel: viewModel, type: type, bundle: bundle)
    }

    public func onSelect(_ handler: ((IndexPath) -> Void)?) {
        self.onSelectHandler = handler
    }

    public func onMove(_ handler: ((_ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void)?) {
        self.onMoveHandler = handler
    }

    public func reloadData() {
        tableView?.reloadData()
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 || !isFirstCellLocked
    }

    public func tableView(_ tableView: UITableView,
                          targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                          toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        Logger.debug(text: "INDEXES: \(sourceIndexPath.row) - \(proposedDestinationIndexPath.row)")

        if isFirstCellLocked, proposedDestinationIndexPath.row == 0 {
            return IndexPath(row: 1, section: proposedDestinationIndexPath.section)
        } else {
            return proposedDestinationIndexPath
        }
    }

    // Handles reordering of Cells
    public func tableView(_ tableView: UITableView,
                          moveRowAt sourceIndexPath: IndexPath,
                          to destinationIndexPath: IndexPath) {
        let element = elements[sourceIndexPath.row]
        elements.remove(at: sourceIndexPath.row)
        elements.insert(element, at: destinationIndexPath.row)

        guard let onMoveHandler = onMoveHandler else { return }

        onMoveHandler(sourceIndexPath, destinationIndexPath)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = elements[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: viewModel.self).reusableIdentifier, for: indexPath)

        viewModel.configure(view: cell)

        return cell
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let actions = elements[indexPath.row].slideActions else { return nil }

        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }

    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let onSelectHandler = onSelectHandler else { return }
        onSelectHandler(indexPath)
    }
}

public extension TableDirector {

    func updateVisibleCells(with values: [any KeyValue]) {

        for element in elements {
            element.update(with: values)
        }

        guard let visibleCells = tableView?.visibleCells,
              let indexPathsForVisibleRows = tableView?.indexPathsForVisibleRows else {
            return
        }

        for (index, indexPath) in indexPathsForVisibleRows.enumerated() {
            let viewModel = elements[indexPath.row]
            let cell = visibleCells[index]

            viewModel.update(view: cell, values: values)
        }
    }

    func configureVisibleCells() {
        if let indexes = tableView?.indexPathsForVisibleRows {
            let cells = tableView?.visibleCells
            let visibleViewModels = indexes.map { $0.row }.compactMap { elements[$0] }
            visibleViewModels.enumerated().forEach { index, element in
                if let cells = cells, index < cells.count {
                    element.configure(view: cells[index])
                }
            }
        }
    }
}
