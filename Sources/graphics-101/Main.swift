import Foundation
import FoundationNetworking
import Wayland

func createImage(width: Int, height: Int) -> Image {
    var image = Image(width: width, height: height, fill: .transparent)

    // TODO: set global clip
    image.fillRoundedRectangle(
        rect: Rect(top: 0, left: 0, width: Float(image.width), height: Float(image.height)),
        cornerRadius: 24
    ) { x, y, _ in
        Color(
            r: Float(x) / Float(width) / 3 + 0.3,
            g: 0.3,
            b: Float(y) / Float(height) / 3 + 0.3,
            a: 1.0)
    }

    let center: (Float, Float) = (280, 280)
    let radius: Float = 180
    image.fillSuperellipse(center: center, radius: radius, degree: 4) {
        x, y, below in
        Color(
            r: (Float(x) - center.0 + radius) / (radius * 2),
            g: (Float(y) - center.1 + radius) / (radius * 2),
            b: 0.5,
            a: 1.0)
    }

    let rect = Rect(top: 24, left: 24, width: 90 * 1.5, height: 195 * 1.5)
    var blurTexture = image.cropped(at: rect)

    blurTexture.blur(radius: 100)

    // TODO: clip
    // image.blit(from: blurTexture, to: rect)

    // TODO: saturation
    image.fillRoundedRectangle(rect: rect, cornerRadius: 48) { x, y, below in
        // below.overlay(.white)
        // below.multiply(scalar: 2)
        blurTexture
            .colorAt(x: x - 24, y: y - 24)
            .multiply(scalar: 2)
            .lerp(Color(r: 0.7, g: 0.7, b: 0.7, a: 1.0), progress: 0.3)
    }

    return image
}

func shi() async throws {
    try FileManager.default.createDirectory(
        at: URL(filePath: "./out"), withIntermediateDirectories: true)

    let clock = ContinuousClock()
    let startTime = clock.now

    await withTaskGroup(of: Void.self) { group in
        for i in (1...10) {
            group.addTask {
                let startTime = clock.now
                let image = createImage(width: 1920, height: 1080)

                print("[g101] Rendered frame \(i) in \(clock.now - startTime)")
                // print("[g101] Writing output...")
                try! image.save(to: URL(filePath: "./ppm/\(i).ppm"))
            }
        }

    }

    print("[g101] Done in \(clock.now - startTime)")
}

@main
struct graphics_101 {
    @MainActor
    static func main() throws {
        let display = try Display()
        display.monitorEvents()

        let window = Window(display: display)

        window.show()

        let observer = RunLoopObserver(on: [.beforeWaiting]) { _ in
            // print("flush")
            display.flush()
        }

        // _ = consume observer

        // Task {
        // let image = createImage(width: 500, height: 500)
        // }
        Task {
            var i = 0
            while !Task.isCancelled {
                print("[count] \(i) (\(Date.now))")
                i += 1
                try await Task.sleep(for: .seconds(1))
            }
        }

        Task {
            print("start \(Date.now)")
            let image = await Task.detached { createImage(width: 640, height: 480) }.value
            print("end \(Date.now)")

            // ideally image.write(to: surface, rect: Rect())
            image.write(to: window.poolData, size: 1000 * 1000 * 4 * 4)  // for now
            window.requestRedraw(flush: false)

            // let value = window.poolData.load(as: UInt32.self)
            // print(String(value, radix: 16))

        }

        RunLoop.main.run()
    }
}
