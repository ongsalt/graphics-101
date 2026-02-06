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

    return ZStack {
        UIBox()
            .background(.red)
            .size([100, 100])
            .offset([count.value / 4, 100])
    }
}
