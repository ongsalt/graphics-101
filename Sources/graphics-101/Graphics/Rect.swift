struct Rect {
    var top: Float
    var left: Float
    var width: Float
    var height: Float

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

    func padded(_ amount: Float) -> Rect {
        Rect(
            top: top + amount, left: left + amount, width: width - 2 * amount,
            height: height - 2 * amount
        )
    }

    func contains(_ position: (Float, Float)) -> Bool {
        let (x, y) = position
        return x >= left && x <= left + width && y >= top && y <= top + height
    }
}
