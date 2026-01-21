class Runtime {
    let rootNode: ActualNode = ActualNode()
    let context: ComponentContext

    init() {
        context = ComponentContext(currentNode: rootNode)
    }

    func runComponent(_ block: () -> some SomeUI) {
        context.startComponent(scope: block)
    }
}
