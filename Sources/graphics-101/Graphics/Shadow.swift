import RealModule

// copied from https://www.shadertoy.com/view/4llXD7
func sdRoundedBox(point: SIMD2<Float>, halfBox: SIMD2<Float>, cornerRadius: Float) -> Float {
    // if the point is inside
    let distance = point.abs() - (halfBox - cornerRadius)
    let outsideDistance = SIMD2<Float>(max(distance.x, 0), max(distance.y, 0)).lenght
    let insideDistance: Float = min(distance.max(), 0) // distance is negative, then clamp to 0

    return insideDistance + outsideDistance - cornerRadius
}


// https://raphlinus.github.io/graphics/2020/04/21/blurred-rounded-rects.html
func sdRoundedBoxSq(point: SIMD2<Float>, halfBox: SIMD2<Float>, cornerRadius: Float) {

}

// TODO: erf7 or smth instead of tanh

extension Image {
    func drawShadow(color: Color, blur: Float, offset: SIMD2<Float> = .zero, distanceFn: ((SIMD2<Float>)) -> Float) {
        let distance = distanceFn(SIMD2(0, 0))
        let opacity = (Float.tan(distance) + 1) / 2        
    }
}

