/// A component must be able to emit/create/mutate the underlying node somehow
/// - 1 node = 1 context
/// - must manage environment
/// - is a tree
/// - destroy context -> destroy component -> call SomeUI.destroy(self)
/// - what if the underlying tree got detroyed -> so there are 2 phase initialization: data, underlying_widget
///     phase 2 must be restartable anytime, phase 1 can be just init() without access to underlying context
///
/// Some functional component might contain more than 1 nodes
/// for now just create a wrapper to make its homogenous
///

@MainActor
protocol UI2 {
    associatedtype PlatformNode = Layer

    // what if its container
    func mount(context: Context2)
    func destroy()
}

extension UI2 {
    func mount(context: Context2) {}
    func destroy() {}
}

class FCRender: UI2 {
    let setup: (Context2) -> Void
    // Phase 1 is for init our tree, then phase 2 is for
    init(_ block: @escaping (Context2) -> Void) {
        self.setup = block
    }

    func mount(context: Context2) {
        // print("mounnnttt")
        setup(context)
        // return []
    }

    // view modifier here????
}

// class FCBuilder<PlatformNode: AnyObject> {
//     public func startComponent(block: () -> Void) {

//     }

//     fileprivate func build() -> (Context2) -> Void {
//         { _ in }
//     }
// }

@MainActor
final class Context2 {
    private unowned var parent: Context2? = nil
    var associatedLayer: Layer? = nil

    func insert(layer: Layer) {
        print("insert")
        associatedLayer?.addChild(layer)
    }

    // TODO: track insertion and perform removal
    func createChildContext() -> Context2 {
        let c = Context2()
        c.parent = self

        return c
    }

    public func startComponent(block: () -> some UI2) {
        block().mount(context: self)
    }
}

struct UIContext {
}
