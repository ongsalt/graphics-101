class Text: UIElement {
    override func measure(constraints: Constraints) -> SIMD2<Float> {
        var w: Float = 0
        var h: Float = 0
        // TODO: measure text

        return constraints.clamp([w, h])
    }

    override func place(area: Rect) {
        super.place(area: area)
        // var area = area
        // TODO: draw the text
    }
}
