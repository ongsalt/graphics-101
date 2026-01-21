class Text2: UI2 {
    private let text: ReadOnlyBinding<String>

    convenience init(_ text: @autoclosure @escaping () -> String) {
        self.init(ReadOnlyBinding(getter: text))
    }

    init(_ text: Bind<String>) {
        self.text = text
    }

    // should be called setup(context: inout ComponentContext)
    func setupWidget(context: Context2) {
        let node = ActualNode()
        context.currentNode.children.append(node)

        // context.effect { ... }
        let effect = Effect {
            print("changed/setup \(self.text.value)")
        }

        context.onDestroy {
            effect.destroy()

            // or should this be auto
            node.remove()
        }
    }
}
