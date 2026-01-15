import Foundation

nonisolated(unsafe) let PAINT_WHITE: (Int, Int) -> Color = { _, _ in .white }

private func isInsideCircle(center: (Float, Float), radius: Float, position: (Float, Float)) -> Bool
{
    let (x, y) = position
    let (cx, cy) = center

    return ((cx - x).squared() + (cy - y).squared()).squareRoot() <= radius
}

private func isInsideSuperellipse(
    center: (Float, Float), radius r: Float, position: (Float, Float), degree: Int = 4
)
    -> Bool
{
    let (x, y) = position
    let (cx, cy) = center

    // Circle
    // (cx - x) ^ 2 + (cy - y) ^ 2 = r ^ 2
    // ((cx - x) / r) ^ 2 + ((cy - y) / r) ^ 2 = 1

    // squircle: change degree to 4?

    return pow((cx - x) / r, Float(degree)) + pow((cy - y) / r, Float(degree)) <= 1
}

private func isInsideRoundedRectangle(
    _ position: (Float, Float), rect r: Rect, cornerRadius: Float, degree: Int = 4
)
    -> Bool
{
    let (x, y) = position

    // there is 4 corner and 2 overlapping rect h and v

    // h
    if r.left + cornerRadius <= x && x <= r.right - cornerRadius && r.top <= y && y <= r.bottom {
        return true
    }

    // v
    if r.left <= x && x <= r.right && r.top + cornerRadius <= y && y <= r.bottom - cornerRadius {
        return true
    }

    // top left
    return isInsideSuperellipse(center: (r.left + cornerRadius, r.top + cornerRadius), radius: cornerRadius, position: (x, y))
    || isInsideSuperellipse(center: (r.left + cornerRadius, r.bottom - cornerRadius), radius: cornerRadius, position: (x, y))
    || isInsideSuperellipse(center: (r.right - cornerRadius, r.top + cornerRadius), radius: cornerRadius, position: (x, y))
    || isInsideSuperellipse(center: (r.right - cornerRadius, r.bottom - cornerRadius), radius: cornerRadius, position: (x, y))
}

extension Image {
    mutating func fillCircle(center: (Float, Float), radius: Float, subpixelCount: Int = 4) {
        let (cx, cy) = center

        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        for x: Int in x1...x2 {
            for y: Int in y1...y2 {
                var covered = 0

                for sx in 0..<subpixelCount {
                    for sy in 0..<subpixelCount {
                        let x = Float(x) + (Float(sx) + 0.5) / Float(subpixelCount)
                        let y = Float(y) + (Float(sy) + 0.5) / Float(subpixelCount)

                        if isInsideCircle(center: center, radius: radius, position: (x, y)) {
                            covered += 1
                        }
                    }
                }

                let p = Float(covered) / Float(subpixelCount * subpixelCount)
                if p == 0 {
                    continue
                }

                let index = getPixelIndex(x: x, y: y)
                let existingColor = pixels[index]

                self.pixels[index] = .white.lerp(existingColor, progress: p)
            }
        }
    }

    mutating func fillShape(
        region: (Int, Int, Int, Int),
        subpixelCount: Int = 4,
        where isInside: (Float, Float) -> Bool,
        paint: (Int, Int) -> Color = PAINT_WHITE
    ) {
        let (x1, x2, y1, y2) = region

        for x: Int in x1...x2 {
            for y: Int in y1...y2 {
                var covered = 0

                for sx in 0..<subpixelCount {
                    for sy in 0..<subpixelCount {
                        let x = Float(x) + (Float(sx) + 0.5) / Float(subpixelCount)
                        let y = Float(y) + (Float(sy) + 0.5) / Float(subpixelCount)

                        if isInside(x, y) {
                            covered += 1
                        }
                    }
                }

                let p = Float(covered) / Float(subpixelCount * subpixelCount)
                if p == 0 {
                    continue
                }

                let index = getPixelIndex(x: x, y: y)
                let existingColor = pixels[index]

                self.pixels[index] = paint(x, y).lerp(existingColor, progress: p)
            }
        }
    }

    mutating func fillCircle(
        center: (Float, Float), radius: Float
    ) {
        let (cx, cy) = center
        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        fillShape(region: (x1, x2, y1, y2)) { x, y in
            isInsideCircle(center: center, radius: radius, position: (x, y))
        } paint: { _, _ in
            .white
        }
    }

    mutating func fillSuperellipse(
        center: (Float, Float), radius: Float, degree: Int = 4,
        paint: (Int, Int) -> Color = PAINT_WHITE
    ) {
        let (cx, cy) = center

        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        fillShape(
            region: (x1, x2, y1, y2), subpixelCount: 4,
            where: { x, y in
                isInsideSuperellipse(
                    center: center, radius: radius, position: (x, y), degree: degree)
            }, paint: paint)
    }

    mutating func fillRoundedRectangle(
        rect: Rect, cornerRadius: Float,
        paint: (Int, Int) -> Color = PAINT_WHITE
    ) {
        fillShape(
            region: (Int(rect.left), Int(rect.right), Int(rect.top), Int(rect.bottom)),
            subpixelCount: 4,
            where: { x, y in
                isInsideRoundedRectangle((x, y), rect: rect, cornerRadius: cornerRadius)
            }, paint: paint)
    }

}
