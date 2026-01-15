import Foundation

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

    func write(to url: URL) throws {
        _ = try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        _ = FileManager.default.createFile(atPath: url.path, contents: nil)
        let file = try FileHandle(forWritingTo: url)

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