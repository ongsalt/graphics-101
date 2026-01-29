@preconcurrency import CVMA
import CoreFoundation
import Foundation
import Synchronization
import Wayland

@main
@MainActor
struct Graphics101 {
    static func main() throws {
        Task {
            let instance = Graphics101()
            try await instance.run()
        }
        RunLoop.main.run()
    }

    func run() async throws {
        let display = try Display()
        display.monitorEvents()

        let window: RawWindow = RawWindow(display: display, title: "yomama")
        window.show()

        let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
            display.dispatchPending()
            display.flush()
        }

        Box(token).leak()

        let vulkanState = VulkanState(
            waylandDisplay: display.display,
            waylandSurface: window.surface.surface
        )

        let renderQueue = RenderQueue(state: vulkanState)
        let renderLoop = try RenderLoop(
            allocator: vulkanState.allocator, device: vulkanState.device,
            swapChain: vulkanState.swapChain)

        let compositor = Compositor(size: [
            Float(vulkanState.swapChain.extent.width), Float(vulkanState.swapChain.extent.height),
        ])

        let l = Layer(rect: Rect(top: 10, left: 10, width: 100, height: 100))
        l.backgroundColor = .red
        compositor.rootLayer.addChild(l)

        // renderQueue.performBs()

        launchCounter()

        Task {
            while !Task.isCancelled {
                let nextFrameTime = ContinuousClock.now.advanced(by: .milliseconds(8))
                await renderQueue.perform(offThread: true) { commandBuffer, swapChain in
                    let info = compositor.flushDrawCommand()
                    renderLoop.apply(info: info, swapChain: swapChain, commandBuffer: commandBuffer)
                }
                try await Task.sleep(until: nextFrameTime)
            }
        }

        // let start = ContinuousClock.now
        // ContiguousArray()

        drop(token)
    }
}
