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
        try runOldImpl()
        return
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
        let renderer = Renderer(state: vulkanState)
        renderer.performBs()

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

            // vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, state.pipeline)
            vkCmdDraw(commandBuffer, 3, 1, 0, 0)
        }

        RunLoop.main.run()
        drop(token)
    }
}
