@preconcurrency import CVMA
import Foundation
import Wayland

// TODO: stroke
struct RoundedRectangleDrawCommand {
    let color: [4 of Color]

    let center: SIMD2<Float>
    let size: SIMD2<Float>

    let borderRadius: Float
    let rotation: Float

    // isShadow

    // brush
    // shadowRadius
    //

    func toVertexData(indexOffset: UInt32 = 0) -> (vertexes: [RoundedRectangleVertexData], indexes: [UInt32]) {
        let halfSize = size / 2
        let vertexes = [
            center - halfSize,
            SIMD2(center.x + halfSize.x, center.y - halfSize.y),
            center + halfSize,
            SIMD2(center.x - halfSize.x, center.y + halfSize.y),
        ].enumerated().map { (i, vertex) in
            RoundedRectangleVertexData(
                color: color[i], 
                center: center, 
                size: size, 
                borderRadius: min(borderRadius, size.min() / 2), 
                rotation: rotation, 
                // isFirstHalf: isFirstHalf, 
                vertex: vertex
            )
        }

        let indexes: [UInt32] = [indexOffset + 0, indexOffset + 1, indexOffset + 2, indexOffset + 0, indexOffset + 3, indexOffset + 2]

        return (vertexes, indexes)
    }
}

struct RoundedRectangleVertexData {
    let color: Color

    let center: SIMD2<Float>
    let size: SIMD2<Float>

    let borderRadius: Float
    let rotation: Float

    // flag
    // let isFirstHalf: UInt32  // actuall a bool tho

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
            offset: UInt32(MemoryLayout<Self>.offset(of: \.color)!)
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
        // .init(
        //     location: 3,
        //     binding: 0,
        //     format: VK_FORMAT_R32_UINT,  // a bool
        //     offset: UInt32(MemoryLayout<Self>.offset(of: \.isFirstHalf)!)
        // ),

        // vertex position
        .init(
            location: 4,
            binding: 0,
            format: VK_FORMAT_R32G32_SFLOAT,  // 2 float
            offset: UInt32(MemoryLayout<Self>.offset(of: \.vertex)!)
        ),

        // use location 8-12 for transformation matrix
    ]

}
