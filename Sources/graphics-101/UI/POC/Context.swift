/// This must:
/// - Keep track of component context
/// - destroy signal when dispose??
///
/// TODO: compare fn component to struct, struct is pain to write but faster
class ComponentContext {
    nonisolated(unsafe) static var current: ComponentContext? = nil

    unowned let parent: ComponentContext? = nil
    // it should own its children
    var childContexts: [ComponentContext] = []
    var environment: Environment

    var currentNode: ActualNode

    init(parent: ComponentContext? = nil, currentNode: ActualNode? = nil) {
        self.environment = Environment(parent: parent?.environment)
        self.parent = parent
        environment.push(self)

        self.currentNode = currentNode ?? parent!.currentNode
    }

    private func createChild(currentNode: ActualNode? = nil) -> ComponentContext {
        let childContext = ComponentContext(parent: self, currentNode: currentNode)
        childContexts.append(childContext)

        return childContext
    }

    func startScope(
        currentNode: ActualNode? = nil,
        scope: (ComponentContext) -> some SomeUI
    ) {
        let childContext = createChild(currentNode: currentNode)
        // TODO: fix this
        let previous = ComponentContext.current
        ComponentContext.current = self

        let setupUi = scope(childContext)
        setupUi.run(context: childContext)

        ComponentContext.current = previous
        // TODO: how to drop it tho
    }

    func startComponent(
        scope: () -> some SomeUI
    ) {
        startScope { context in
            scope()
        }
    }

    func startIf(
        _ condition: @escaping () -> Bool, then: @escaping () -> Void,
        else _else: (() -> Void)? = nil
    ) {
        let condition = Computed(tags: ["context"], condition)

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

    func destroy() {
        for child in self.childContexts {
            child.destroy()
        }
    }

    deinit {
        destroy()
    }
}
