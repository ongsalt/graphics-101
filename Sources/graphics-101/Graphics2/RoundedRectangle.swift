@preconcurrency import CVMA
import Foundation
import Wayland

struct RoundedRectangleDrawCommand {
    // let color: [3 of Color]  // 3 * 4 f32
    let color: Color

    let center: SIMD2<Float>
    let size: SIMD2<Float>

    let borderRadius: Float
    let rotation: Float

    // flag
    let isFirstHalf: UInt32  // actuall a bool tho
    // isShadow

    // brush
    // shadowRadius
    //

    func toVertexData() -> (vertexes: [RoundedRectangleShaderData], indexes: [UInt32]) {
        let halfSize = size / 2
        let vertexes: [RoundedRectangleShaderData] = [
            .init(shape: self, vertex: center - halfSize),
            .init(shape: self, vertex: SIMD2(center.x + halfSize.x, center.y - halfSize.y)),
            .init(shape: self, vertex: center + halfSize),
            .init(shape: self, vertex: SIMD2(center.x - halfSize.x, center.y + halfSize.y)),
        ]

        let indexes: [UInt32] = [0, 1, 2, 0, 3, 2]

        return (vertexes, indexes)
    }
}

struct RoundedRectangleShaderData {
    let shape: RoundedRectangleDrawCommand
    let vertex: SIMD2<Float>

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
            offset: UInt32(MemoryLayout<Self>.offset(of: \.shape.color)!)
        ),
        // center, w, h
        .init(
            location: 1,
            binding: 0,
            format: VK_FORMAT_R32G32B32A32_SFLOAT,  // 4 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.shape.center)!)
        ),
        // borderRadius, rotation
        .init(
            location: 2,
            binding: 0,
            format: VK_FORMAT_R32G32_SFLOAT,  // 2 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.shape.borderRadius)!)
        ),
        // isFirstHalf
        .init(
            location: 3,
            binding: 0,
            format: VK_FORMAT_R32_UINT,  // a bool
            offset: UInt32(MemoryLayout<Self>.offset(of: \.shape.isFirstHalf)!)
        ),

        // vertex position
        .init(
            location: 4,
            binding: 0,
            format: VK_FORMAT_R32G32_SFLOAT,  // 2 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.vertex)!)
        ),
    ]

}
