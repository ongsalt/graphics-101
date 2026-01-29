struct Rect {
    static let zero = Rect(top: 0, left: 0, width: 0, height: 0)

    var top: Float
    var left: Float
    var width: Float
    var height: Float

    init(
        top: Float, left: Float, width: Float, height: Float
    ) {
        self.top = top
        self.left = left
        self.width = width
        self.height = height
    }

    init(
        center: SIMD2<Float>, size: SIMD2<Float>
    ) {
        self.top = center.y - size.y / 2
        self.left = center.x - size.x / 2
        self.width = size.x
        self.height = size.y
    }

    var right: Float {
        get {
            left + width
        }
        set {
            width = newValue - left
        }
    }

    var bottom: Float {
        get {
            top + height
        }
        set {
            height = newValue - bottom
        }
    }

    var center: SIMD2<Float> {
        SIMD2(left + width / 2, top + height / 2)
    }

    var topLeft: SIMD2<Float> {
        SIMD2(left, top)
    }

    var size: SIMD2<Float> {
        SIMD2(width, height)
    }

    var atOrigin: Rect {
        Rect(top: 0, left: 0, width: width, height: height)
    }

    func padded(_ amount: Float) -> Rect {
        Rect(
            top: top - amount, left: left - amount, width: width + 2 * amount,
            height: height + 2 * amount
        )
    }

    func offset(_ offset: SIMD2<Float>) -> Rect {
        Rect(top: top + offset.y, left: left + offset.x, width: width, height: height)
    }

    func contains(_ position: (Float, Float)) -> Bool {
        let (x, y) = position
        return x >= left && x <= left + width && y >= top && y <= top + height
    }
}
