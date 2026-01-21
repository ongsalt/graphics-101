func Counter2(props: @autoclosure @escaping () -> Int) -> some UI2 {
    Counter(props: Bind(getter: props))
}

func Counter2(props: Bind<Int>) -> some UI2 {
    let count = Signal(0)

    return ComponentUI { context in
        context.startComponent {
            Text("props: \(props)")
        }

        context.startComponent {
            Text("count: \(count)")
        }
    }
}
