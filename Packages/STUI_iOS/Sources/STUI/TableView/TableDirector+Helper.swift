//
//  TableDirector+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension TableDirector {
    static func label(with text: String?,
                      key: String = UUID().uuidString,
                      layout: Layout,
                      image: UIImage? = nil,
                      tapHandler: ((CodeValue<String>) -> Void)? = nil) -> GroupCellViewModel<[any ViewViewModel]> {
        let viewModel = LabelViewModel(param: CodeValue<String>(keys: [ key ], value: text ?? ""),
                                       layout:layout,
                                       image: image,
                                       handleTap: tapHandler)

        return GroupCellViewModel<[any ViewViewModel]>(childViewModels: [ viewModel ],
                                                       layout: layout,
                                                       isCard: false)
    }

    static func button(with text: String?,
                       key: String = UUID().uuidString,
                       layout: Layout,
                       tapHandler: @escaping (CodeValue<ButtonInput>) -> Void) -> GroupCellViewModel<[any ViewViewModel]> {

        let input = ButtonInput(title: text, alignment: .center)
        let viewModel = ButtonViewModel(param: CodeValue<ButtonInput>(keys: [ key ], value: input),
                                        layout:layout,
                                        handleButtonTouched: tapHandler)

        return GroupCellViewModel<[any ViewViewModel]>(childViewModels: [ viewModel ],
                                                       layout: layout,
                                                       isCard: false)
    }

}
