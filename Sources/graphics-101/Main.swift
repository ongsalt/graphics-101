import Foundation
import FoundationNetworking
import Wayland

@main
struct Graphics101 {
    static func main() throws {
        let instance = Graphics101()
        try instance.run()
    }

    func run() throws {

        let display = try Display()
        display.monitorEvents()
        // auto flush?
        let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
            // print("flush")
            display.flush()
        }

        let window = RawWindow(display: display, title: "yomama")
        window.show()

        let vulkanState = VulkanState(
            waylandDisplay: display,
            waylandSurface: window.surface
        )

        let renderLoop = RenderLoop(state: vulkanState)
        renderLoop.run()

        // window.show()

        print("done")

        RunLoop.main.run()
        _ = consume token
    }
}
