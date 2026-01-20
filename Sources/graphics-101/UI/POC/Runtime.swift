/// This must:
/// - Keep track of component context
/// - destroy signal when dispose??
///
/// TODO: compare fn component to struct, struct is pain to write but faster
class ComponentContext {
    nonisolated(unsafe) static var current: ComponentContext? = nil

    let parent: ComponentContext? = nil
    var environment: Environment

    var emittedNodes: [ActualNode] = []

    init(parent: ComponentContext? = nil) {
        self.environment = Environment(parent: parent?.environment)
        self.parent = parent
        environment.push(self)
    }

    private func startScope<T>(_ scope: (ComponentContext) -> T) -> T {
        let childContext = ComponentContext(parent: self)
        // TODO: fix this
        let previous = ComponentContext.current
        ComponentContext.current = self
        let ret = scope(childContext)
        ComponentContext.current = previous
        // TODO: how to drop it tho
        return ret
    }

    func startComponent(_ block: () -> some SomeUI) {
        startScope { runtime in
            let setupUi = block()
            setupUi.run(runtime: runtime)
        }
    }

    func startIf(
        _ condition: @escaping () -> Bool, then: @escaping () -> Void,
        else _else: (() -> Void)? = nil
    ) {
        let condition = Computed(tags: ["runtime"], condition)

        // Effect {
        //     if condition.value {
        //         // how do i untrack thow
        //         then()
        //     } else {
        //         _else?()
        //     }
        // }
    }

    func startFor<Item>(
        _ condition: @escaping () -> [Item], item: @escaping () -> Void
    ) {

    }
}
