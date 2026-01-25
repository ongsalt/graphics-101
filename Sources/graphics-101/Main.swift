@preconcurrency import CVMA
import CoreFoundation
import Foundation
import Synchronization
import Wayland

@main
@MainActor
struct Graphics101 {
    static func main() throws {
        let instance = Graphics101()
        try instance.run()
    }

    func run() throws {
        let display = try Display()
        display.monitorEvents()
        // let wlQueue = display.createQueue()
        // let displayProxy = try display.createSelfProxy(queue: wlQueue)

        let window: RawWindow = RawWindow(display: display, title: "yomama")
        window.show()
        // TODO: window.xdgTopLevel

        let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
            // print("will sleep")
            // display.flush()
        }

        let vulkanState = VulkanState(
            waylandDisplay: display.display,
            waylandSurface: window.surface.surface
                // waylandDisplay: display.createProxy(for: display.display, queue: wlQueue),
                // waylandSurface: display.createProxy(for: window.surface.surface, queue: wlQueue)
        )

        let uniformBuffer: GPUBuffer<Float32> = GPUBuffer(
            data: [800, 600],
            allocator: vulkanState.allocator,
            device: vulkanState.device,
            count: 2,
            usages: VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT
        )

        func updateUBO() {
            uniformBuffer.set([800, 600])
        }

        let (vertexData, indexes) = RoundedRectangleDrawCommand(
            color: [Color.white, Color.white, Color.white, Color.white],
            center: SIMD2(400, 300),
            size: SIMD2(160, 120) * 2,
            borderRadius: 48,
            rotation: 0,
            isFirstHalf: 0
        ).toVertexData()

        // we should pool it
        let buffer = GPUBuffer(
            vertexBuffer: vertexData, allocator: vulkanState.allocator, device: vulkanState.device)
        let indexBuffer = GPUBuffer(
            indexBuffer: indexes, allocator: vulkanState.allocator, device: vulkanState.device)

        let renderer = Renderer(state: vulkanState)
        // renderer.performBs()

        let pipeline = GraphicsPipeline(
            device: vulkanState.device,
            swapChain: vulkanState.swapChain,
            vertexShader: try Shader(
                filename: "rounded_rectangle.vert.spv", device: vulkanState.device),
            fragmentShader: try Shader(
                filename: "rounded_rectangle.frag.spv", device: vulkanState.device),
            binding: .init(
                bindingDescriptions: [RoundedRectangleShaderData.bindingDescriptions],
                attributeDescriptions: RoundedRectangleShaderData.attributeDescriptions
            )
        )

        func updateVertex() {
            let time = sin(Date.now.timeIntervalSince1970 * 4)
            let a = (time + 1) / 7 + 2
            let (vertexData, indexes) = RoundedRectangleDrawCommand(
                color: [Color.white, Color.white, Color.white, Color.white],
                center: SIMD2(400, 300),
                size: SIMD2(160, 120) * Float(a),
                borderRadius: 64,
                rotation: 0,
                isFirstHalf: 0
            ).toVertexData()

            buffer.mapped.initialize(from: vertexData)
            indexBuffer.mapped.initialize(from: indexes)
        }

        var drawned: Int64 = 0

        func render() {
            let finished = renderer.perform(blocking: true) { commandBuffer, swapChain in
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

                var offsets: [UInt64] = [0]
                pipeline.bind(commandBuffer: commandBuffer)

                vkCmdBindVertexBuffers(commandBuffer, 0, 1, &buffer.buffer, &offsets)
                vkCmdBindIndexBuffer(commandBuffer, indexBuffer.buffer, 0, VK_INDEX_TYPE_UINT32)

                // 2. Bind the descriptor set inside your command buffer recording loop
                // vkCmdBindDescriptorSets(
                //     commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS,
                //     pipeline.pipelineLayout, 0, 1, descriptorSet, 0, nil)
                var address = uniformBuffer.deviceAddress
                vkCmdPushConstants(
                    commandBuffer, pipeline.pipelineLayout, VK_SHADER_STAGE_VERTEX_BIT.rawValue,
                    0,
                    UInt32(MemoryLayout<VkDeviceAddress>.size), &address
                )

                vkCmdDrawIndexed(commandBuffer, UInt32(indexes.count), 1, 0, 0, 0)
            }

            if finished {
                drawned += 1
            }

            // Logger.info(.renderLoop, "\(finished ? "finished" : "cancelled")")
        }

        launchCounter()

        let start = ContinuousClock.now
        // ContiguousArray()

        func queueRender() {
            DispatchQueue.main.async(qos: .userInitiated) {
                updateVertex()
                render()
                display.dispatchPending()
                queueRender()
            }
        }

        Task {
            while !Task.isCancelled {
                try await Task.sleep(for: .seconds(1))
                print(
                    "fps: \(drawned / max((ContinuousClock.now - start).components.seconds, 1))"
                )
            }
        }

        // while true {
        //     render()
        //     display.dispatchPending()
        //     RunLoop.main.limitDate(forMode: .default)
        // }

        queueRender()

        RunLoop.main.run()
        drop(token)
    }
}
