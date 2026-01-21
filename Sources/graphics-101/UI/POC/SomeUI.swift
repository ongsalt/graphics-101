// import CWayland

protocol SomeUI {
    func run(context: ComponentContext)
    func destroy(context: ComponentContext)
}

extension SomeUI {
    func destroy(context: ComponentContext) {}

}

class ActualNode: Identifiable {
    var children: [ActualNode] = []
    unowned let parent: ActualNode? = nil

    func remove() {
        parent!.children.removeAll { $0.id == self.id }
    }
}

class ComponentUI: SomeUI {
    let setup: (ComponentContext) -> Void
    init(_ setup: @escaping (ComponentContext) -> Void) {
        self.setup = setup
    }

    func run(context: ComponentContext) {
        setup(context)
    }
}
