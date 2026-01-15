import Foundation

@main
struct graphics_101 {
    static func main() async throws {
        // for ffpmpeg
        try FileManager.default.createDirectory(
            at: URL(filePath: "./out"), withIntermediateDirectories: true)

        await withTaskGroup { group in
            // for i in (1...4) {
                group.addTask {
                    var image = Image(width: 640, height: 640)

                    image.fillSuperellipse(center: (320, 320), radius: 200, degree: 4) { x, y in
                        Color(
                            r: Float(x - 120) / 400,
                            g: Float(y - 120) / 400,
                            b: 0.5,
                            a: 1.0)
                    }


                    image.fillRoundedRectangle(rect: Rect(top: 24, left: 24, width: 90 * 1.5, height: 195 * 1.5), cornerRadius: 32)


                    try! image.write(to: URL(filePath: "./ppm/\(1).ppm"))
                }
            // }
        }
    }
}
