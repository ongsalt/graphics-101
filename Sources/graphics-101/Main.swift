import Foundation
import Wayland

func shi() async throws {
    try FileManager.default.createDirectory(
        at: URL(filePath: "./out"), withIntermediateDirectories: true)

    let clock = ContinuousClock()
    let startTime = clock.now

    await withTaskGroup(of: Void.self) { group in
        for i in (1...10) {
            group.addTask {
                let startTime = clock.now
                var image = Image(width: 1920, height: 1080, fill: .grey)
                image.fillRectangle(
                    rect: Rect(
                        top: 0, left: 0, width: Float(image.width), height: Float(image.height))
                ) { x, y, _ in
                    Color(
                        r: Float(x) / 1920 / 3 + 0.3,
                        g: 0.3,
                        b: Float(y) / 1080 / 3 + 0.3,
                        a: 1.0)
                }

                let center: (Float, Float) = (640, 640)
                let radius: Float = 420
                image.fillSuperellipse(center: center, radius: radius, degree: 4) {
                    x, y, below in
                    Color(
                        r: (Float(x) - center.0 + radius) / (radius * 2),
                        g: (Float(y) - center.1 + radius) / (radius * 2),
                        b: 0.5,
                        a: 1.0)
                }

                let rect = Rect(top: 24, left: 24, width: 90 * 4, height: 195 * 4)
                var blurTexture = image.cropped(at: rect)

                blurTexture.blur(radius: 100)

                // TODO: clip
                // image.blit(from: blurTexture, to: rect)

                // TODO: saturation
                image.fillRoundedRectangle(rect: rect, cornerRadius: 48 * 3) { x, y, below in
                    // below.overlay(.white)
                    // below.multiply(scalar: 2)
                    blurTexture
                        .colorAt(x: x - 24, y: y - 24)
                        .multiply(scalar: 2)
                        .lerp(Color(r: 0.7, g: 0.7, b: 0.7, a: 1.0), progress: 0.3)
                }

                print("[g101] Rendered frame \(i) in \(clock.now - startTime)")
                // print("[g101] Writing output...")
                try! image.write(to: URL(filePath: "./ppm/\(i).ppm"))
            }
        }

    }

    print("[g101] Done in \(clock.now - startTime)")
}

@main
struct graphics_101 {
    static func main() throws {
        let display = try Display()

        DispatchQueue.global().async {
            // epoll here then
            // MainActor.run { }
        }

        print("next")
        // Task {
        //     try await Task.sleep(for: .seconds(1))
        //     print("sdsfds")
        // }

        // how do i interface with wayland shit tho
        let port = SocketPort()

        RunLoop.main.run()
    }
}
