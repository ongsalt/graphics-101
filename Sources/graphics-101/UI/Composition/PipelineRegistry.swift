@preconcurrency import CVMA

class PipelineRegistry {
    let main: GraphicsPipeline

    init(device: VkDevice, swapChain: SwapChain) throws {
        main = GraphicsPipeline(
            device: device,
            swapChain: swapChain,
            vertexShader: try Shader(filename: "rounded_rectangle.vert.spv", device: device),
            fragmentShader: try Shader(filename: "rounded_rectangle.frag.spv", device: device),
            binding: .init(
                bindingDescriptions: [RoundedRectangleVertexData.bindingDescriptions],
                attributeDescriptions: RoundedRectangleVertexData.attributeDescriptions
            )
        )
    }
}
