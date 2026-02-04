@MainActor
class UIRuntime {
    let root: Layer

    init(root: Layer, setupFn: () -> some UI2) {
        self.root = root
        let context = Context2()
        context.associatedLayer = root

        let ui = setupFn()
        ui.mount(context: context)
    }
}