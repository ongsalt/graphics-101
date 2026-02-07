// https://freetype.org/freetype2/docs/glyphs/glyphs-2.html

struct Point: RawRepresentable {
    let rawValue: UInt

    init(_ rawValue: UInt) {
        self.rawValue = rawValue
    }

    // Conforming to RawRepresentable
    init?(rawValue: UInt) {
        self.rawValue = rawValue
    }

    func toPixel(dpi: Float) -> UInt {
        UInt(Float(rawValue) * dpi / 72)
    }
}
