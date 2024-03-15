//
//  FlowMoreItem.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

public struct FlowMoreItem {
    let imageName: String
    let name: String
    let link: String
}

public let sensorTileBoxFlowMoreItems: [FlowMoreItem] = [
    FlowMoreItem(imageName: "flow_more_book", name: "Technical documentation", link: "https://www.st.com/SensorTilebox#documentation"),
    FlowMoreItem(imageName: "flow_more_support", name: "Help & Support", link: "https://www.st.com/SensorTilebox"),
    FlowMoreItem(imageName: "flow_more_board_web", name: "About SensorTile.box", link: "https://www.st.com/SensorTilebox"),
    FlowMoreItem(imageName: "flow_more_web", name: "ST Website", link: "https://www.st.com/")
]

public let sensorTileBoxProFlowMoreItems: [FlowMoreItem] = [
    FlowMoreItem(imageName: "flow_more_book", name: "Technical documentation", link: "https://www.st.com/en/evaluation-tools/steval-mkboxpro.html#documentation"),
    FlowMoreItem(imageName: "flow_more_support", name: "Help & Support", link: "https://www.st.com/en/evaluation-tools/steval-mkboxpro.html"),
    FlowMoreItem(imageName: "flow_more_board_web", name: "About SensorTile.box-Pro", link: "https://www.st.com/en/evaluation-tools/steval-mkboxpro.html"),
    FlowMoreItem(imageName: "flow_more_web", name: "ST Website", link: "https://www.st.com/"),
    FlowMoreItem(imageName: "flow_more_book", name: "Custom Fw Db Entry", link: "https://raw.githubusercontent.com/STMicroelectronics/appconfig/release/bluestsdkv2/custom/steval_mkboxpro/DefaultFw_0_9_0.json")
]
