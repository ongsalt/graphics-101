import Foundation

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
        paint: (Int, Int) -> Color = { _, _ in .white }
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
        paint: (Int, Int) -> Color = { _, _ in .white }
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

}
