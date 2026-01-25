@preconcurrency import CVMA
import Foundation
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
        let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
            display.flush()
        }

        let window: RawWindow = RawWindow(display: display, title: "yomama")
        // window.show()
        // TODO: window.xdgTopLevel

        let vulkanState = VulkanState(
            waylandDisplay: display,
            waylandSurface: window.surface
        )

        let vertexData: [RoundedRectangleShaderData] = [
            // TODO: this should produce 4 point, 6 index
            .init(
                vertexColor: Color.blue, center: (0.4, 0.4), size: (0.2, 0.3), borderRadius: 0.1,
                rotation: 0, isFirstHalf: 0),
            .init(
                vertexColor: Color.blue, center: (0.6, 0.6), size: (0.2, 0.3), borderRadius: 0.1,
                rotation: 0, isFirstHalf: 0),
            .init(
                vertexColor: Color.blue, center: (0.6, 0.4), size: (0.2, 0.3), borderRadius: 0.1,
                rotation: 0, isFirstHalf: 0),
        ]

        let buffer = GPUBuffer(
            data: vertexData, allocator: vulkanState.allocator, device: vulkanState.device)

        let renderer = Renderer(state: vulkanState)
        // renderer.performBs()

        let pipeline = GraphicsPipeline(
            device: vulkanState.device,
            swapChain: vulkanState.swapChain,
            shader: try Shader(filename: "rounded_rectangle", device: vulkanState.device),
            binding: .init(
                bindingDescriptions: [RoundedRectangleShaderData.bindingDescriptions],
                attributeDescriptions: RoundedRectangleShaderData.attributeDescriptions
            )
        )

        // renderer.performBs()

        renderer.perform { commandBuffer, swapChain in
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

            vkCmdDraw(commandBuffer, 3, 1, 0, 0)
        }

        RunLoop.main.run()
        drop(token)
    }
}
