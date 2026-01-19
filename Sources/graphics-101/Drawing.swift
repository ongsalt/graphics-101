// TODO: reuse image texture
func createImage(width: Int, height: Int, padding: Float = 8, cornerRadius: Float = 72) -> Image {
    var image = Image(width: width, height: height, fill: .transparent)

    let bound = Rect(
        top: padding, left: padding, width: Float(image.width) - 2 * padding,
        height: Float(image.height) - 2 * padding)

    // TODO: set global clip

    image.fillRoundedRectangle(
        rect: bound,
        cornerRadius: cornerRadius
    ) { x, y, _ in
        Color(
            r: Float(x) / Float(width) / 3 + 0.3,
            g: 0.3,
            b: Float(y) / Float(height) / 3 + 0.3,
            a: 1.0)
    }

    image.fillRoundedRectangleBorder(
        rect: bound,
        cornerRadius: cornerRadius,
        borderWidth: 1
    ) { x, y, below in
        .red
    }

    let center: (Float, Float) = (280, 280)
    let radius: Float = 180
    // image.fillSuperellipse(center: center, radius: radius, degree: 4) {
    image.fillRectangle(
        rect: Rect(
            top: center.1 - radius, left: center.0 - radius, width: radius * 2, height: radius * 2)
    ) {
        x, y, below in
        Color(
            r: ((Float(x) - center.0) + radius) / (radius * 2),
            g: (-(Float(y) - center.1) + radius) / (radius * 2),
            b: 0.5,
            a: 1.0)
    }

    let rect = Rect(top: 24, left: 24, width: 90 * 1.5, height: 195 * 1.5)
    var blurTexture = image.cropped(at: rect)

    // box blur look like shit
    blurTexture.blur(radius: 25)
    blurTexture.blur(radius: 25)

    // TODO: clip
    // image.blit(from: blurTexture, to: rect)

    // TODO: saturation
    image.fillRoundedRectangle(rect: rect, cornerRadius: 48) { x, y, below in
        // below.overlay(.white)
        // below.multiply(scalar: 2)
        blurTexture
            .colorAt(x: x - 24, y: y - 24)
            // probably gonna do brighness curve shit
            .multiply(scalar: 1.7)
            .lerp(Color(r: 0.7, g: 0.7, b: 0.7, a: 1.0), progress: 0.3)
    }

    return image
}
