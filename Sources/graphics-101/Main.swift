import Foundation

@main
struct graphics_101 {
    static func main() async throws {
        // for ffpmpeg
        try FileManager.default.createDirectory(
            at: URL(filePath: "./out"), withIntermediateDirectories: true)

        await withTaskGroup { group in
            for i in (1...4) {
                group.addTask {
                    var image = Image(width: 640, height: 640)

                    for x in 0..<image.width {
                        for y in 0..<image.height {
                            // buffer.append(contentsOf: [)
                            image.pixels.append(
                                Color(
                                    r: Float(x) / Float(image.width),
                                    g: Float(y) / Float(image.height),
                                    b: 0.5,
                                    a: 1.0))
                        }
                    }

                    image.fillSuperellipse(center: (320, 320), radius: 200, degree: i * 2)
                    try! image.write(to: URL(filePath: "./ppm/\(i).ppm"))
                }
            }
        }
    }
}
