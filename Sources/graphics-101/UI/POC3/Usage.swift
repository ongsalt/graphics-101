@MainActor
func Counter() -> some UIElement {
    let count: Signal<Float> = Signal(0.0)

    Task {
        while !Task.isCancelled {
            try await Task.sleep(for: .seconds(1))
            count.value += 1
        }
    }

    return ZStack {
        UIBox()
            .background(.red)
            .size([100, 100])
            .offset([100 * count.value, 100])
    }
}
