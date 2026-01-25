import RealModule
import Foundation

// copied from https://www.shadertoy.com/view/4llXD7
func sdRoundedBox(point: SIMD2<Float>, halfBox: SIMD2<Float>, cornerRadius: Float) -> Float {
    // if the point is inside
    let distance = point.abs() - (halfBox - cornerRadius)
    let outsideDistance = SIMD2<Float>(max(distance.x, 0), max(distance.y, 0)).lenght
    let insideDistance: Float = min(distance.max(), 0)  // distance is negative, then clamp to 0

    return insideDistance + outsideDistance - cornerRadius
}

// https://raphlinus.github.io/graphics/2020/04/21/blurred-rounded-rects.html
func sdRoundedBoxSq(point: SIMD2<Float>, halfBox: SIMD2<Float>, cornerRadius: Float) {

}

extension Image {
    mutating func drawShadow(
        region: (Int, Int, Int, Int),
        color: Color,
        blur: Float,
        offset: SIMD2<Float> = .zero,
        distanceFn: ((SIMD2<Float>)) -> Float
    ) {
        let w = Double(4 / blur)

        let (x1, x2, y1, y2) = region

        // TODO: better bounding
        for x: Int in x1..<x2 {
            for y: Int in y1..<y2 {
                let d: Float = distanceFn(SIMD2<Float>(Float(x) + 0.5, Float(y) + 0.5))
                // print(x, y, d)
                // if d < 0 {

                // }
                let progress = Float(d) / blur
                if d > blur || d < -3 {
                    continue
                }

                let index = self.getPixelIndex(x: x, y: y)
                let existingColor = pixels[index]

                // do super sampling for edge
                // if d < 0 {
                //     let subpixelCount = 2
                //     var alpha: Float = 0

                //     for sx in 0..<subpixelCount {
                //         for sy in 0..<subpixelCount {
                //             let x = Float(x) + (Float(sx) + 0.5) / Float(subpixelCount)
                //             let y = Float(y) + (Float(sy) + 0.5) / Float(subpixelCount)

                //             let d: Float = distanceFn(SIMD2<Float>(Float(x), Float(y)))
                //             let progress = Float(d) / blur
                //             alpha += Float.pow(1 - progress, 2)
                //         }
                //     }

                //     alpha /= Float(subpixelCount * subpixelCount)
                //     self.pixels[index] = color.lerp(over: existingColor, progress: alpha)

                //     continue
                // }

                // let alpha = Double(progress).erf()
                let alpha = Float.pow(1 - progress, 3)

                // if progress.isNaN {
                //     continue
                // }

                self.pixels[index] = color.lerp(over: existingColor, progress: alpha)
                // self.pixels[index] = Color.init(progress, 0, 0, 1)
            }
        }
        // pad  = blur
    }

    mutating func drawRoundedRectangleShadow(
        rect: Rect,
        cornerRadius: Float,
        color: Color,
        blur: Float,
        offset: SIMD2<Float> = .zero,
    ) {
        // let halfBox = SIMD2<Float>(rect.width, rect.height) / 2
        // let center = SIMD2<Float>(rect.left, rect.top) + halfBox

        drawShadow(
            region: (
                Int(floor(rect.left - blur)),
                Int(ceil(rect.right + blur)),
                Int(floor(rect.top - blur)),
                Int(ceil(rect.bottom + blur)),
            ),
            color: color,
            blur: blur
        ) { position in
            sdfRoundedRectangle(position, rect: rect, cornerRadius: cornerRadius)
            // sdRoundedBox(point: position - center, halfBox: halfBox, cornerRadius: cornerRadius)
        }
    }
}
