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

    func randomRect() -> RoundedRectangleDrawCommand {
        RoundedRectangleDrawCommand(
            color: duplicated(
                Color(Float.random(in: 0...1), .random(in: 0...1), .random(in: 0...1), 0.5)
                    .premulitplied()
            ),
            center: SIMD2(.random(in: 0...800), .random(in: 0...600)),
            size: SIMD2(.random(in: 50...200), .random(in: 50...200)),
            borderRadius: .random(in: 50...200),
            rotation: 0,
        )
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
            // display.dispatchPending()
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

        var (vertexData, indexes) = randomRect().toVertexData()
        var indexCount = indexes.count

        // we should pool it
        let buffer = GPUBuffer(
            vertexBuffer: vertexData, allocator: vulkanState.allocator, device: vulkanState.device)
        let indexBuffer = GPUBuffer(
            indexBuffer: indexes, allocator: vulkanState.allocator, device: vulkanState.device)

        let renderQueue = RenderQueue(state: vulkanState)
        // renderQueue.performBs()

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

        var rects: [RoundedRectangleDrawCommand] = [
            randomRect()
        ]

        let start = ContinuousClock.now

        // well, we shuold not do this every frame

        func updateVertex() {
            let time = ContinuousClock.now
            let d = (time - start).components.seconds * 2
            if d > rects.count {
                let r = randomRect()
                let res = r.toVertexData(indexOffset: UInt32(rects.count) * 4)
                rects.append(r)
                vertexData.append(contentsOf: res.vertexes)
                indexes.append(contentsOf: res.indexes)
                // print("Add")
                buffer.mapped.initialize(from: vertexData)
                indexBuffer.mapped.initialize(from: indexes)
                indexCount = indexes.count
            }
            // let a = (time + 1) / 7 + 2

            // print(vertexData.count)

        }

        var drawned: Int64 = 0

        func render() {
            let finished = renderQueue.perform() { commandBuffer, swapChain in
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

                // print(indexCount)
                vkCmdDrawIndexed(commandBuffer, UInt32(indexCount), 1, 0, 0, 0)
            }

            if finished {
                drawned += 1
            }

            // Logger.info(.renderLoop, "\(finished ? "finished" : "cancelled")")
        }

        launchCounter()

        // let start = ContinuousClock.now
        // ContiguousArray()

        func queueRender() {
            let now = DispatchTime.now().uptimeNanoseconds
            DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: now + 1000 * 1000 * 2), qos: .userInitiated, flags: DispatchWorkItemFlags()) {
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
                    "drawed: \(drawned) / frame: \(max((ContinuousClock.now - start).components.seconds, 1))"
                )
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
