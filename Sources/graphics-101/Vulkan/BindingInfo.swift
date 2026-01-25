@preconcurrency import CVMA
import Foundation
import Wayland

struct BindingInfo {
    let bindingDescriptions: [VkVertexInputBindingDescription]
    let attributeDescriptions: [VkVertexInputAttributeDescription]

    static let none: BindingInfo = BindingInfo(bindingDescriptions: [], attributeDescriptions: [])
}
