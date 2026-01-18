import Foundation

// bruh this is literally a shader
typealias PaintFn = (Int, Int, Color) -> Color

nonisolated(unsafe) let PAINT_WHITE: PaintFn = { _, _, _ in .white }

private func isInsideCircle(_ position: (Float, Float), center: (Float, Float), radius: Float)
    -> Bool
{
    let (x, y) = position
    let (cx, cy) = center

    return ((cx - x).squared() + (cy - y).squared()).squareRoot() <= radius
}

// its not actually distance
private func distanceFromSuperellipse(
    _ position: (Float, Float), center: (Float, Float), radius r: Float, degree: Int = 4
)
    -> Float
{
    let (x, y) = position
    let (cx, cy) = center

    return pow(abs(cx - x) / r, Float(degree)) + pow(abs(cy - y) / r, Float(degree))
}

private func isInsideSuperellipse(
    _ position: (Float, Float), center: (Float, Float), radius r: Float, degree: Int = 4
)
    -> Bool
{
    return distanceFromSuperellipse(position, center: center, radius: r, degree: degree) <= 1
}

private func isInsideRoundedRectangle(
    _ position: (Float, Float), rect r: Rect, cornerRadius cr: Float, degree: Int = 4
)
    -> Bool
{
    let (x, y) = position
    let cr = min(cr, min(r.width, r.height) / 2)

    // there is 4 corner and 2 overlapping rect h and v

    // h
    if r.left + cr <= x && x <= r.right - cr && r.top <= y && y <= r.bottom {
        return true
    }

    // v
    if r.left <= x && x <= r.right && r.top + cr <= y && y <= r.bottom - cr {
        return true
    }

    return isInsideSuperellipse((x, y), center: (r.left + cr, r.top + cr), radius: cr, )
        || isInsideSuperellipse((x, y), center: (r.left + cr, r.bottom - cr), radius: cr)
        || isInsideSuperellipse((x, y), center: (r.right - cr, r.top + cr), radius: cr)
        || isInsideSuperellipse((x, y), center: (r.right - cr, r.bottom - cr), radius: cr)
}

// TODO: think about rotation: transform coordination system or do it directly
private func isInsideRoundedRectangleBorder(
    _ position: (Float, Float), rect r: Rect, cornerRadius cr: Float, degree: Int = 4,
    borderWidth: Float = 1
)
    -> Bool
{
    let (x, y) = position
    let cr = min(cr, min(r.width, r.height) / 2)

    let w = borderWidth / 2

    let isLeft = x < r.left + cr
    let isRight = x > r.right - cr
    let isTop = y < r.top + cr
    let isBottom = y > r.bottom - cr

    // Corner Logic
    if (isLeft || isRight) && (isTop || isBottom) {
        let centerX = isLeft ? r.left + cr : r.right - cr
        let centerY = isTop ? r.top + cr : r.bottom - cr

        return isInsideSuperellipse(
            position, center: (centerX, centerY), radius: cr + w, degree: degree)
            && !isInsideSuperellipse(
                position, center: (centerX, centerY), radius: cr - w, degree: degree)
    }

    return abs(r.left - x) <= w || abs(r.right - x) <= w
        || abs(r.top - y) <= w || abs(r.bottom - y) <= w
}

extension Image {
    mutating func fillCircle(center: (Float, Float), radius: Float, subpixelCount: Int = 2) {
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

                        if isInsideCircle((x, y), center: center, radius: radius) {
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
        subpixelCount: Int = 2,
        where isInside: (Float, Float) -> Bool,
        paint: PaintFn = PAINT_WHITE,
    ) {
        let (x1, x2, y1, y2) = region

        for x: Int in x1..<x2 {
            for y: Int in y1..<y2 {
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

                self.pixels[index] = paint(x, y, existingColor).lerp(existingColor, progress: p)
            }
        }
    }

    mutating func fillCircle(
        center: (Float, Float),
        radius: Float
    ) {
        let (cx, cy) = center
        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        fillShape(region: (x1, x2, y1, y2)) { x, y in
            isInsideCircle((x, y), center: center, radius: radius)
        }
    }

    mutating func fillSuperellipse(
        center: (Float, Float),
        radius: Float,
        degree: Int = 4,
        paint: PaintFn = PAINT_WHITE
    ) {
        let (cx, cy) = center

        let x1 = Int(floor(cx - radius))
        let x2 = Int(ceil(cx + radius))
        let y1 = Int(floor(cy - radius))
        let y2 = Int(ceil(cy + radius))

        fillShape(
            region: (x1, x2, y1, y2),
            subpixelCount: 4,
            where: { x, y in
                isInsideSuperellipse((x, y), center: center, radius: radius, degree: degree)
            },
            paint: paint
        )
    }

    mutating func fillRectangle(
        rect: Rect,
        paint: PaintFn = PAINT_WHITE
    ) {
        fillShape(
            region: (Int(rect.left), Int(rect.right), Int(rect.top), Int(rect.bottom)),
            subpixelCount: 4,
            where: { _, _ in true },
            paint: paint
        )
    }

    mutating func fillRoundedRectangle(
        rect: Rect,
        cornerRadius: Float,
        paint: PaintFn = PAINT_WHITE
    ) {
        fillShape(
            region: (Int(rect.left), Int(rect.right), Int(rect.top), Int(rect.bottom)),
            subpixelCount: 4,
            where: { x, y in
                isInsideRoundedRectangle((x, y), rect: rect, cornerRadius: cornerRadius)
            },
            paint: paint
        )
    }

    mutating func fillRoundedRectangleBorder(
        rect: Rect,
        cornerRadius: Float,
        borderWidth: Float = 1,
        paint: PaintFn = PAINT_WHITE
    ) {
        let w = borderWidth / 2
        fillShape(
            region: (
                Int(rect.left - w), Int(rect.right + w),
                Int(rect.top - w), Int(rect.bottom + w)
            ),
            subpixelCount: 4,
            where: { x, y in
                isInsideRoundedRectangleBorder(
                    (x, y), rect: rect, cornerRadius: cornerRadius, borderWidth: borderWidth)
            },
            paint: paint
        )
    }

}
