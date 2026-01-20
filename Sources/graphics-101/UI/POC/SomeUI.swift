// import CWayland

protocol SomeUI {
    func run(runtime: ComponentContext) -> Void
}

struct ActualNode {}

class ComponentUI: SomeUI {
    let setup: (ComponentContext) -> Void
    init (_ setup: @escaping (ComponentContext) -> Void) {
        self.setup = setup
    }

    func run(runtime: ComponentContext) -> Void {
        setup(runtime)
    }

}