//
//  DemoGroupFilterView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STDemos
import STUI

struct DemoGroupFilterView: View {

    let orderingBy: OrderByGroup
    let demosGroup: [DemoGroup]

    let completion: (FilterParameters) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var selectedGroups: Set<DemoGroup>

    @State
    private var selectedOrder: OrderByGroup

    init(
        orderingBy: OrderByGroup,
        demosGroup: [DemoGroup],
        completion: @escaping (FilterParameters) -> Void
    ) {
        self.orderingBy = orderingBy
        self.demosGroup = demosGroup
        self.completion = completion

        _selectedGroups = State(initialValue: Set(demosGroup))
        _selectedOrder = State(initialValue: orderingBy)
    }

    var body: some View {

        NavigationStack {

            Form {

                orderingSection

                filtersSection
            }
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button(Localizer.Common.cancel.localized) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {

                    Button(Localizer.Common.ok.localized) {

                        completion(
                            FilterParameters(
                                orderingBy: selectedOrder,
                                demosGroup: Array(selectedGroups)
                            )
                        )

                        dismiss()
                    }
                }
            }
        }
    }
}

private extension DemoGroupFilterView {

    var orderingSection: some View {

        Section("Ordering by") {
            
            FlowLayout(spacing: 10) {
                
                ForEach(OrderByGroup.allCases, id: \.self) { order in
                    
                    FilterChip(
                        title: order.rawValue,
                        isSelected: selectedOrder == order
                    ) {
                        selectedOrder = (selectedOrder == order) ? .none : order
                    }
                }
            }
        }
    }
}

private extension DemoGroupFilterView {

    var filtersSection: some View {

        Section(Localizer.Catalog.Text.filters.localized) {

            FlowLayout(spacing: 10) {

                ForEach(DemoGroup.allCases, id: \.self) { group in

                    FilterChip(
                        title: group.rawValue,
                        isSelected: selectedGroups.contains(group)
                    ) {

                        if selectedGroups.contains(group) {
                            selectedGroups.remove(group)
                        } else {
                            selectedGroups.insert(group)
                        }
                    }
                }
            }
        }
    }
}
