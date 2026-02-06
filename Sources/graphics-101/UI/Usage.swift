@MainActor
func Counter() -> some UIElement {
    let count: Signal<Float> = Signal(0.0)

    Compositor.current?.requestAnimationFrame { time in
        count.value = Float(time.attoseconds / 1_000_000_000_000_000)
        // print(count.value)
        if count.value > 4800 {
            return .done
        }
        return .ongoing
    }

    return VStack(gap: 12) {
        UIBox()
            .background(.red)
            .size([100, 100])
            .offset([count.value / 4, 0])
        UIBox()
            .background(.green)
            .size([100, 100])
        UIBox()
            .background(.blue)
            .size([100, 100])
            .cornerRadius(36)
        UIBox()
            .background(.white)
            .size([100, 100])
            .cornerRadius(36)
            .shadow(color: .black.multiply(opacity: 0.3), blur: 24)
            // .withLayer { layer in
            //     layer.
            // }

    }
}
