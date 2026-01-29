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

        let window: RawWindow = RawWindow(display: display, title: "yomama")
        window.show()

        let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
            display.dispatchPending()
            display.flush()
        }

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

        // TODO: request animation frame
        Task {
            try await Task.sleep(for: .seconds(0.5))

            let l = Layer(rect: Rect(top: 10, left: 10, width: 100, height: 100))
            l.backgroundColor = .red
            compositor.rootLayer.addChild(l)

            compositor.requestAnimationFrame { progress in
                let t = progress / Duration.milliseconds(400)
                if t > 1 {
                    l.scale = 1
                    l.opacity = 1
                    return .done
                }

                // apply p
                let p = 1 - Float.pow(1 - Float(t), 3)

                l.scale = 1 - 0.2 + p * 0.2
                l.opacity = p

                return .ongoing
            }
        }

        // renderQueue.performBs()

        launchCounter()

        Task {
            while !Task.isCancelled {
                let nextFrameTime = ContinuousClock.now.advanced(by: .milliseconds(8))
                await renderQueue.perform(offThread: true) { commandBuffer, swapChain in
                    compositor.runAnimation()
                    let info = compositor.flushDrawCommand()
                    renderLoop.apply(info: info, swapChain: swapChain, commandBuffer: commandBuffer)
                }
                try await Task.sleep(until: nextFrameTime)
            }
        }

        // let start = ContinuousClock.now
        // ContiguousArray()

        RunLoop.main.run()
        drop(token)
    }
}
