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

        RunLoop.main.run()
        _ = consume token
    }
}
