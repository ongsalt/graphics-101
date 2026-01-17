struct Color {
    let r: Float
    let g: Float
    let b: Float
    let a: Float

    static let black = Color(r: 0, g: 0, b: 0, a: 1)
    static let white = Color(r: 1, g: 1, b: 1, a: 1)
    static let grey = Color(r: 0.5, g: 0.5, b: 0.5, a: 1)
    static let blue = Color(r: 0, g: 0, b: 1, a: 1)
    static let transparent = Color(r: 0, g: 0, b: 0, a: 0)

    func toUInt8() -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        (
            r: UInt8(r.clamp(0, 1) * 255),
            g: UInt8(g.clamp(0, 1) * 255),
            b: UInt8(b.clamp(0, 1) * 255),
            a: UInt8(a.clamp(0, 1) * 255)
        )
    }

    func toUInt32() -> UInt32 {
        let (r, g, b, a) = toUInt8()
        return (UInt32(r) << (0 * 8)) // 0x12
            | (UInt32(g) << (1 * 8))  // 0x3400
            | (UInt32(b) << (2 * 8))  // 0x560000
            | (UInt32(a) << (3 * 8))  // 0x78000000
    }

    // shitty alpha blending
    func lerp(_ other: Color, progress p: Float) -> Color {
        let p2 = 1 - p
        return Color(
            r: r * p + other.r * p2, g: g * p + other.g * p2, b: b * p + other.b * p2,
            a: a * p + other.a * p2)
    }

    func mutiply(_ other: Color) -> Color {
        Color(
            r: r * other.r,
            g: g * other.g,
            b: b * other.b,
            a: a * other.a
        )
    }

    func multiply(scalar mutiplier: Float) -> Color {
        Color(r: mutiplier * r, g: mutiplier * g, b: mutiplier * b, a: a)
    }

    func screen(_ other: Color) -> Color {
        Color(
            r: 1 - (1 - r) * (1 - other.r),
            g: 1 - (1 - g) * (1 - other.g),
            b: 1 - (1 - b) * (1 - other.b),
            a: 1 - (1 - a) * (1 - other.a)
        )
    }

    func overlay(_ other: Color) -> Color {
        Color(
            r: r < 0.5 ? 2 * r * other.r : 1 - 2 * (1 - r) * (1 - other.r),
            g: g < 0.5 ? 2 * g * other.g : 1 - 2 * (1 - g) * (1 - other.g),
            b: b < 0.5 ? 2 * b * other.b : 1 - 2 * (1 - b) * (1 - other.b),
            // a: a < 0.5 ? 2 * a * other.a : 1 - 2 * (1 - a) * (1 - other.a)
            a: 1
        )
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Color(r: lhs.r + rhs.r, g: lhs.g + rhs.g, b: lhs.b + rhs.b, a: max(lhs.a, rhs.a))
    }

}
