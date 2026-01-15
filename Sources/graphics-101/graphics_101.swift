import Foundation

func isInside(center: (Float, Float), radius: Float, position: (Float, Float)) -> Bool {
    let (x, y) = position
    let (cx, cy) = center

    return ((cx - x).squared() + (cy - y).squared()).squareRoot() <= radius
}

extension Image {
    mutating func fillCircle(center: (Float, Float), radius: Float, subpixelCount: Int = 4) {
        let (cx, cy) = center

        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        for x: Int in x1...x2 {
            for y: Int in y1...y2 {
                var covered = 0

                for sx in 0..<subpixelCount {
                    for sy in 0..<subpixelCount {
                        let x = Float(x) + (Float(sx) + 0.5) / Float(subpixelCount)
                        let y = Float(y) + (Float(sy) + 0.5) / Float(subpixelCount)

                        if isInside(center: center, radius: radius, position: (x, y)) {
                            covered += 1
                        }
                    }
                }

                let p = Float(covered) / Float(subpixelCount * subpixelCount)
                if p == 0 {
                    continue
                }

                let index = getPixelIndex(x: x, y: y)
                let existingColor = pixels[index]

                self.pixels[index] = .white.lerp(existingColor, progress: p)
            }
        }
    }
}

@main
struct graphics_101 {
    static func main() async throws {
        // for ffpmpeg
        _ = try FileManager.default.createDirectory(
            at: URL(filePath: "./out"), withIntermediateDirectories: true)

        await withTaskGroup { group in
            for i in (1...5) {
                group.addTask {
                    var image = Image(width: 640, height: 640)

                    for x in 0..<image.width {
                        for y in 0..<image.height {
                            // buffer.append(contentsOf: [)
                            image.pixels.append(
                                Color(
                                    r: Float(x) / Float(image.width),
                                    g: Float(y) / Float(image.height),
                                    b: 1.0,
                                    a: 1.0))
                        }
                    }

                    image.fillCircle(center: (320, 320), radius: 200, subpixelCount: i)
                    try! image.write(to: URL(filePath: "./ppm/\(i).ppm"))
                }
            }
        }
    }
}
