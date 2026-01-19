import Foundation
import FoundationNetworking
import Wayland
import CVulkan

@main
struct graphics_101 {
    @MainActor
    static func main() throws {
        let display = try Display()

        let width = 640
        let height = 480

        let shm = SharedMemoryBuffer(
            shm: display.registry.sharedMemoryBuffer)
        let pool = shm.createPool(size: Int32(width * height * 4 * 4))

        let window = Window(display: display, pool: pool)
        window.show()

        // vkCreateInstance(UnsafePointer<VkInstanceCreateInfo>!, UnsafePointer<VkAllocationCallbacks>!, UnsafeMutablePointer<VkInstance?>!)

        // launchCounter()

        // _ = consume observer

        // window.surface.onFrame(runImmediately: true) {
        //     // print("called")
        //     padding += 1






        var padding: Float = 12

        Task { [padding] in
            let start = ContinuousClock.now
            let image = await Task.detached { [padding] in
                createImage(width: 640, height: 480, padding: padding)
            }.value

            // ideally image.write(to: surface, rect: Rect())
            image.write(to: window.currentBuffer.bufferData)  // for now
            window.requestRedraw()
            let end = ContinuousClock.now
            // print("Done in \(end - start)")
            // bruh
        }

        display.monitorEvents()
        // auto flush?
        let observationToken = RunLoop.main.observe(on: [.beforeWaiting]) { _ in
            // print("flush")
            display.flush()
        }

        RunLoop.main.run()
    }
}


