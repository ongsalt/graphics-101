import Foundation

struct Image {
    var pixels: [Color]
    let width: Int
    let height: Int
    var rect: Rect {
        Rect(top: 0, left: 0, width: Float(width), height: Float(height))
    }

    init(width: Int, height: Int, fill fillColor: Color? = nil) {
        self.width = width
        self.height = height
        pixels = Array(repeating: fillColor ?? .black, count: width * height)
    }

    // func cropped(rect: Rect) -> Image {
    //     let image = Image(width: Int(rect.width), height: Int(rect.height))
    //     return image
    // }

    func cropped(at rect: Rect) -> Image {
        var newImage = Image(width: Int(rect.width), height: Int(rect.height))

        let x1 = Int(rect.left)
        let x2 = Int(rect.right)
        let y1 = Int(rect.top)
        let y2 = Int(rect.bottom)

        for x in x1..<x2 {
            for y in y1..<y2 {
                let color = pixels[getPixelIndex(x: x, y: y)]
                newImage.pixels[newImage.getPixelIndex(x: x - x1, y: y - y1)] = color
            }
        }

        return newImage
    }

    // TODO: float and antialiasing
    // TODO: opacity and blending
    mutating func blit(from other: Image, at area: Rect, to targetPosition: (Int, Int)) {
        let x1 = Int(area.left)
        let x2 = Int(area.right)
        let y1 = Int(area.top)
        let y2 = Int(area.bottom)

        let (tx, ty) = targetPosition

        for x in x1..<x2 {
            for y in y1..<y2 {
                let color = other.pixels[other.getPixelIndex(x: x, y: y)]
                pixels[getPixelIndex(x: x - x1 + tx, y: y - y1 + ty)] = color
            }
        }
    }

    mutating func blit(from other: Image, to: Rect) {
        blit(
            from: other, at: Rect(top: 0, left: 0, width: to.width, height: to.height),
            to: (Int(to.left), Int(to.top)))
    }

    // TODO: fix edge
    func getPixelIndex(x: Int, y: Int, fillEdge: Bool = true) -> Int {
        let x = max(0, min(x, self.width - 1))
        let y = max(0, min(y, self.height - 1))
        // print(x, y)
        return x + y * width
    }

    func colorAt(x: Int, y: Int, fillEdge: Bool = true) -> Color {
        pixels[getPixelIndex(x: x, y: y, fillEdge: fillEdge)]
    }

    func write(to buffer: UnsafeMutableRawBufferPointer) {
        let buffer = buffer.assumingMemoryBound(to: UInt32.self)

        for (offset, pixel) in pixels.enumerated() {
            buffer[offset] = pixel.toARGB8888()
        }
    }

    func save(to url: URL) throws {
        _ = try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

        _ = FileManager.default.createFile(atPath: url.path, contents: nil)
        let file = try FileHandle(forWritingTo: url)

        try file.write(contentsOf: "P3\n\(width) \(height)\n255\n".data(using: .ascii)!)

        var buffer = ""
        for p in pixels {
            let (r, g, b, _) = p.toUInt8()
            buffer += "\(r) \(g) \(b) "
        }

        try file.write(contentsOf: buffer.data(using: .ascii)!)
        try file.close()
    }

}
