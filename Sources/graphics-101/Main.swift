import Foundation

@main
struct graphics_101 {
    static func main() async throws {
        // for ffpmpeg
        try FileManager.default.createDirectory(
            at: URL(filePath: "./out"), withIntermediateDirectories: true)

        print("[g101] rendering")
        await withTaskGroup { group in
            // for i in (1...4) {
            group.addTask {
                var image = Image(width: 1920, height: 1080, fill: Color.grey)
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

                image.fillSuperellipse(center: (320, 320), radius: 200, degree: 4) { x, y, _ in
                    Color(
                        r: Float(x - 120) / 400,
                        g: Float(y - 120) / 400,
                        b: 0.5,
                        a: 1.0)
                }

                let rect = Rect(top: 24, left: 24, width: 90 * 1.5, height: 195 * 1.5)
                image.fillRoundedRectangle(rect: rect, cornerRadius: 48) { x, y, below in
                    below.overlay(.white)
                }

                try! image.write(to: URL(filePath: "./ppm/\(1).ppm"))
            }

            // }
        }
        print("[g101] done")

    }
}
