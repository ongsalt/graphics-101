struct Color {
    let r: Float
    let g: Float
    let b: Float
    let a: Float

    static let black = Color(r: 0, g: 0, b: 0, a: 1)
    static let white = Color(r: 1, g: 1, b: 1, a: 1)
    static let transparent = Color(r: 0, g: 0, b: 0, a: 0)

    func toUInt8() -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        (
            r: UInt8(min(r, 1) * 255), g: UInt8(min(g, 1) * 255), b: UInt8(min(b, 1) * 255),
            a: UInt8(min(a, 1) * 255)
        )
    }

    // shitty alpha blending
    func lerp(_ other: Color, progress p: Float) -> Color {
        let p2 = 1 - p
        return Color(
            r: r * p + other.r * p2, g: g * p + other.g * p2, b: b * p + other.b * p2,
            a: a * p + other.a * p2)
    }

}
