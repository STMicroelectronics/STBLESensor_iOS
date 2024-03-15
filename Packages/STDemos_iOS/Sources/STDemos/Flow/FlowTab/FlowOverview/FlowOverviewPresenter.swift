//
//  FlowOverviewPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class FlowOverviewPresenter: BasePresenter<FlowOverviewViewController, FlowAndNodeParam> {
    var director: TableDirector?
}

// MARK: - FlowOverviewViewControllerDelegate
extension FlowOverviewPresenter: FlowOverviewDelegate {

    func load() {
        view.configureView()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowItemViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: FlowOverviewButtonViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
        }
        
        /// FLOW NAME
        let nameFlowViewModel = LabelViewModel(
            param: CodeValue<String>(value: param.flow.descr),
            layout: Layout.title
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: nameFlowViewModel, layout: Layout.standard))

        /// FLOW DESCRIPTION LABEL
        let descrLabelFlowViewModel = LabelViewModel(
            param: CodeValue<String>(value: "Description"),
            layout: Layout.infoBold
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: descrLabelFlowViewModel, layout: Layout.standard))
        
        
        /// FLOW DESCRIPTION
        if let flowNotes = param.flow.notes {
            let descriptionFlowViewModel = LabelViewModel(
                param: CodeValue<String>(value: flowNotes),
                layout: Layout.info
            )
            director?.elements.append(ContainerCellViewModel(childViewModel: descriptionFlowViewModel, layout: Layout.standard))
        }
        
        /// FLOW APP OVERVIEW
        let appOverviewViewModel = LabelViewModel(
            param: CodeValue<String>(value: "App Overview"),
            layout: Layout.title
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: appOverviewViewModel, layout: Layout.standard))
        
        /// FLOW APP OVERVIEW BUTTON
        let buttonsViewModel = FlowOverviewButtonViewModel(
            param: (),
            editButtonTouched: { self.editButtonTapped() },
            playButtonTouched: { self.playButtonTapped() }
        )
        director?.elements.insert(buttonsViewModel, at: director?.elements.count ?? 0)
        
        /// INPUT
        let inputLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Input"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_down", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: inputLabelViewModel, layout: Layout.standard))

        director?.elements.append(contentsOf: param.flow.inputs.map({ input in
            FlowItemViewModel(
                param: input,
                isInOverviewMode: true,
                onFlowItemSettingsClicked: { sensorItem in },
                onFlowItemDeleteClicked: { sensorItem in }
            )
        }))
        
        /// FUNCTION
        let functionLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Function"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_down", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: functionLabelViewModel, layout: Layout.standard))
        
        director?.elements.append(contentsOf: param.flow.functions.map({ fun in
            FlowItemViewModel(
                param: fun,
                isInOverviewMode: true,
                onFlowItemSettingsClicked: { functionItem in},
                onFlowItemDeleteClicked: { functionItem in }
            )
        }))
        
        /// OUTPUT
        let outputLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Output"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_end", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: outputLabelViewModel, layout: Layout.standard))
        
        director?.elements.append(contentsOf: param.flow.outputs.map({ output in
            FlowItemViewModel(
                param: output,
                isInOverviewMode: true,
                onFlowItemSettingsClicked: { outputItem in },
                onFlowItemDeleteClicked: { outputItem in }
            )
        }))
        
        director?.reloadData()
    }
    
    func playButtonTapped() {
        let flowUploadController = FlowUploadPresenter(param: param)
        flowUploadController.configure(with: [param.flow])
        
        self.view.navigationController?.pushViewController(
            flowUploadController.start(),
            animated: true
        )
    }
    
    func editButtonTapped() {
        let newFlowController = NewFlowPresenter(param: param)
        self.view.navigationController?.pushViewController(
            newFlowController.start(),
            animated: true
        )
    }
}

