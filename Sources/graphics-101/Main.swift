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

        func addRect(rect: Rect) {
            // print(rect)
            let l = Layer(rect: rect)
            l.backgroundColor = Color.red.multiply(opacity: 0.2)
            l.cornerRadius = 36
            compositor.rootLayer.addChild(l)

            compositor.requestAnimationFrame { progress in
                let t = progress / Duration.milliseconds(300)
                if t > 1 {
                    l.scale = 1
                    l.opacity = 1
                    return .done
                }

                // apply p
                let p = 1 - Float.pow(1 - Float(t), 4)

                l.scale = 1 - 0.2 + p * 0.2
                l.opacity = p

                return .ongoing
            }
        }

        Task {
            while !Task.isCancelled {
                try await Task.sleep(for: .seconds(0.5))
                addRect(
                    rect: Rect(
                        center: [.random(in: 0...800), .random(in: 0...600)],
                        size: .random(in: 50...200)
                    )
                )
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
                display.dispatchPending()
                try await Task.sleep(until: nextFrameTime)
            }
        }

        // let start = ContinuousClock.now
        // ContiguousArray()

        RunLoop.main.run()
        drop(token)
    }
}
