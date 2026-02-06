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

        let renderer = try UIRenderer(
            state: vulkanState, onFinishCallback: { display.dispatchPending() })

        let compositor = Compositor(
            renderer: renderer,
            size: [
                Float(vulkanState.swapChain.extent.width),
                Float(vulkanState.swapChain.extent.height),
            ]
        )

        Compositor.current = compositor

        // let l = Layer(rect: Rect.init(center: [100,100], size: [100,100]))
        // l.backgroundColor = .red
        // compositor.rootLayer.addChild(l)

        let runtime = UIRuntime(
            layer: compositor.rootLayer, 
            element: BaseBox()
                .background(.red)
                .size([100, 100])
        )
        runtime.start()

        // print("\(compositor.rootLayer.children[0].bounds)")


        // renderQueue.performBs()

        // launchCounter()
        // compositor.start()

        // Task {
        //     while !Task.isCancelled {
        //         let nextFrameTime = ContinuousClock.now.advanced(by: .milliseconds(8))
        //         await renderQueue.perform(offThread: true) { commandBuffer, swapChain in
        //             compositor.runAnimation()
        //             let info = compositor.flushDrawCommand()
        //             renderer.apply(info: info, swapChain: swapChain, commandBuffer: commandBuffer)
        //         }
        //         display.dispatchPending()
        //         try await Task.sleep(until: nextFrameTime)
        //     }
        // }

        // let start = ContinuousClock.now
        // ContiguousArray()

        RunLoop.main.run()
        drop(token)
    }
}
