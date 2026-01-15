import Foundation

extension Numeric {
    func squared() -> Self {
        return self * self
    }
}

struct Color {
    let r: Float
    let g: Float
    let b: Float
    let a: Float

    static let black = Color(r: 0, g: 0, b: 0, a: 1)
    static let white = Color(r: 1, g: 1, b: 1, a: 1)

    func toUInt8() -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        (r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255), a: UInt8(a * 255))
    }

    // shitty alpha blending
    func lerp(_ other: Color, progress p: Float) -> Color {
        let p2 = 1 - p
        return Color(
            r: r * p + other.r * p2, g: g * p + other.g * p2, b: b * p + other.b * p2,
            a: a * p + other.a * p2)
    }

}

struct Image {
    var pixels: [Color] = []
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        pixels.reserveCapacity(width * height)
    }

    func getPixelIndex(x: Int, y: Int) -> Int {
        x + y * width
    }

    func colorAt(x: Int, y: Int) -> Color {
        pixels[getPixelIndex(x: x, y: y)]
    }

    func writeOutput() throws {
        let newFilePath = URL(filePath: "./out.ppm")

        _ = FileManager.default.createFile(atPath: newFilePath.path, contents: nil)
        let file = try FileHandle(forWritingTo: newFilePath)

        try file.write(contentsOf: "P3\n\(width) \(height)\n255\n".data(using: .ascii)!)

        var buffer = ""
        for p in pixels {
            let (r, g, b, a) = p.toUInt8()
            buffer += "\(r) \(g) \(b)\n"
        }

        try file.write(contentsOf: buffer.data(using: .ascii)!)
        try file.close()
    }
}

func isInside(center: (Float, Float), radius: Float, position: (Float, Float)) -> Bool {
    let (x, y) = position
    let (cx, cy) = center

    return ((cx - x).squared() + (cy - y).squared()).squareRoot() <= radius
}

func fillCircle(center: (Float, Float), radius: Float, image: inout Image) {
    let (cx, cy) = center
    let subpixelCount = 4  // its 4 by 4 -> 16

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

            let index = image.getPixelIndex(x: x, y: y)
            let existingColor = image.pixels[index]

            image.pixels[index] = existingColor.lerp(.black, progress: 1 - p)
        }
    }
}

@main
struct graphics_101 {
    static func main() throws {
        var image = Image(width: 640, height: 640)

        for x in 0..<image.width {
            for y in 0..<image.height {
                // buffer.append(contentsOf: [)
                image.pixels.append(
                    Color(
                        r: Float(x) / Float(image.width), g: Float(y) / Float(image.height), b: 1.0,
                        a: 1.0))
            }
        }

        fillCircle(center: (100, 100), radius: 50, image: &image)

        try image.writeOutput()
    }
}
