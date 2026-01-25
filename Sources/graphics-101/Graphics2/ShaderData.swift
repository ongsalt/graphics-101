@preconcurrency import CVMA
import Foundation
import Wayland


struct RoundedRectangleShaderData {
    // let vertexColor: [3 of Color]  // 3 * 4 f32
    let vertexColor: Color

    let center: (Float, Float)
    let size: (Float, Float)

    let borderRadius: Float
    let rotation: Float

    // flag
    let isFirstHalf: UInt32  // actuall a bool tho
    // isShadow

    // brush
    // shadowRadius
    //

    // we convert this to struct of array
    static let bindingDescriptions: VkVertexInputBindingDescription = .init(
        binding: 0,
        stride: UInt32(MemoryLayout<Self>.size),
        inputRate: VK_VERTEX_INPUT_RATE_VERTEX
    )

    static let attributeDescriptions: [VkVertexInputAttributeDescription] = [
        // Color
        .init(
            location: 0,
            binding: 0,
            format: VK_FORMAT_R32G32B32A32_SFLOAT,  // 4 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.vertexColor)!)
        ),
        // center, w, h
        .init(
            location: 1,
            binding: 0,
            format: VK_FORMAT_R32G32B32A32_SFLOAT,  // 4 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.center)!)
        ),
        // borderRadius, rotation
        .init(
            location: 2,
            binding: 0,
            format: VK_FORMAT_R32G32_SFLOAT,  // 2 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.borderRadius)!)
        ),
        // isFirstHalf
        .init(
            location: 3,
            binding: 0,
            format: VK_FORMAT_R32_UINT,  // a bool
            offset: UInt32(MemoryLayout<Self>.offset(of: \.isFirstHalf)!)
        ),
    ]
}
