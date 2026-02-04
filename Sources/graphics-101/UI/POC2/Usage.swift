import Foundation

@MainActor
func Counter2(props: @autoclosure @escaping () -> Int) -> some UI2 {
    Counter2(props: Bind(getter: props))
}

@MainActor
func Counter2(props: Bind<Int>) -> some UI2 {
    let count: Signal<Float> = Signal(0.0)
    // print("Component setup")

    Compositor.current?.requestAnimationFrame { time in
        count.value = Float(time.attoseconds / 10000000000000000 * 2)
        return .ongoing
    }

    return FCRender { context in
        // print("Component render")
        context.startComponent {
            UIBox()
                .background(.red)
                .bounds(Rect(top: 12, left: 12, width: 100, height: 100))
                .cornerRadius(count.value)
                .scale(count.value / 100 + 1)
        }

        // context.startComponent {
        //     // Text("count: \(count)")
        // }
    }
}

/// if there is ViewModifier
/// execution order: function body -> (register child) -> view modifier -> run child
/// or just do LocalCompositor or someshi
