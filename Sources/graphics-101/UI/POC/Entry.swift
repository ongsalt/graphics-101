// or
// @Component(coare: true)
// or (reactToNonBindingChange: true) ???
// func Text(_ text: String) {
//     print("[Text] renderer \(text)")
// }

class Text: SomeUI {
    private let text: ReadOnlyBinding<String>

    convenience init(_ text: @autoclosure @escaping () -> String) {
        self.init(ReadOnlyBinding(getter: text))
    }

    init(_ text: Bind<String>) {
        self.text = text
    }

    // should be called setup(context: inout ComponentContext)
    func run(runtime context: ComponentContext) {
        let node = ActualNode()
        context.addNode(node)

        let effect = Effect {
            print("changed/setup \(self.text.value)")
        }

        context.onDestroy {
            effect.destroy()
        }
    }
}

func Counter(props: @autoclosure @escaping () -> Int) -> some SomeUI {
    Counter(props: Bind(getter: props))
}

func Counter(props: Bind<Int>) -> some SomeUI {
    let count = Signal(0)

    return ComponentUI { runtime in
        runtime.startComponent {
            Text("props: \(props)")
        }

        runtime.startComponent {
            Text("count: \(count)")
        }
    }
}

func CounterWrapper() -> some SomeUI {
    let props = Signal(12)
    let show = Signal(true)

    return ComponentUI { runtime in
        // Counter(props: 0)
        runtime.startComponent {
            Counter(props: props.toReadOnly())
        }

        // runtime.startIf {
        //     show.value
        // } then: {
        //     Text("Show")
        // }
    }
}

func runUi() {
    let ui = CounterWrapper()

    let runtime = ComponentContext()

    ui.run(runtime: runtime)
}
