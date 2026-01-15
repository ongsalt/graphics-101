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
}