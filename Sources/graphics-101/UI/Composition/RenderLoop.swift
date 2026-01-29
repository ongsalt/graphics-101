@preconcurrency import CVMA

@MainActor
class RenderLoop {
    // 1 buffer, each shader will get different offset in this
    let pipelines: PipelineRegistry
    let buffer: RawGPUBuffer
    let uniformBuffer: GPUBuffer<(Float32, Float32)>

    var shouldRender: Bool = false

    init(allocator: VmaAllocator, device: VkDevice, swapChain: SwapChain) throws {
        pipelines = try PipelineRegistry(device: device, swapChain: swapChain)
        buffer = RawGPUBuffer(
            allocator: allocator,
            device: device,
            size: 1024 * 1024,
            usages: VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
        )

        uniformBuffer = GPUBuffer(
            data: [(800, 600)],
            allocator: allocator,
            device: device,
            count: 1,
            usages: VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT
        )
    }

    // vsync loop

    // TODO: damaged area
    func apply(info: DrawInfo, swapChain: SwapChain, commandBuffer: VkCommandBuffer) {
        // vulkan shit
        var bufferOffset = 0

        // info.damagedArea
        setViewport(swapChain: swapChain, commandBuffer: commandBuffer)

        for cmd in info.commands {
            switch cmd {
            case .main(let vertexes, let indexes):
                let pipeline = pipelines.main
                let vertexBufferOffset = bufferOffset
                bufferOffset += buffer.write(vertexes, offset: bufferOffset)
                let indexBufferOffset = bufferOffset
                bufferOffset += buffer.write(indexes, offset: bufferOffset)

                var offsets: [UInt64] = [UInt64(vertexBufferOffset)]
                
                pipeline.bind(commandBuffer: commandBuffer)

                vkCmdBindVertexBuffers(commandBuffer, 0, 1, &buffer.buffer, &offsets)
                vkCmdBindIndexBuffer(
                    commandBuffer, buffer.buffer, UInt64(indexBufferOffset), VK_INDEX_TYPE_UINT32)

                var address = uniformBuffer.deviceAddress
                vkCmdPushConstants(
                    commandBuffer, pipeline.pipelineLayout, VK_SHADER_STAGE_VERTEX_BIT.rawValue,
                    0,
                    UInt32(MemoryLayout<VkDeviceAddress>.size), &address
                )

                vkCmdDrawIndexed(commandBuffer, UInt32(indexes.count), 1, 0, 0, 0)

            // add pipeline to renderqueue + vertex data
            }
        }
    }
}

private func setViewport(swapChain: SwapChain, commandBuffer: VkCommandBuffer) {
    var viewport = VkViewport(
        x: 0,
        y: 0,
        width: Float(swapChain.extent.width),
        height: Float(swapChain.extent.height),
        minDepth: 0.0,
        maxDepth: 1.0
    )
    vkCmdSetViewport(commandBuffer, 0, 1, &viewport)

    var scissor = VkRect2D(
        offset: VkOffset2D(x: 0, y: 0),
        extent: swapChain.extent
    )
    vkCmdSetScissor(commandBuffer, 0, 1, &scissor)
}
