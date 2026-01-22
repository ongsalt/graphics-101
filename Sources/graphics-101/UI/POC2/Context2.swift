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

protocol UI2 {
    associatedtype PlatformNode: AnyObject

    // what if its container
    func setupWidget(context: Context2<PlatformNode>)
    func destroy()
}

extension UI2 {
    func setupWidget(context: Context2<PlatformNode>) {}
    func destroy() {}
}

class FCRender<PlatformNode: AnyObject>: UI2 {
    let setup: (Context2<PlatformNode>) -> Void
    // Phase 1 is for init our tree, then phase 2 is for
    init(_ block: @escaping (FCBuilder<PlatformNode>) -> Void) {
        let builder = FCBuilder<PlatformNode>()
        block(builder)
        self.setup = builder.build()
    }

    func setupWidget(context: Context2<PlatformNode>) -> [PlatformNode] {
        setup(context)
        return []
    }
}

class FCBuilder<PlatformNode: AnyObject> {
    public func startComponent(block: () -> Void) {
        
    }

    fileprivate func build() -> (Context2<PlatformNode>) -> Void {
        { _ in }
    }
}

final class Context2<PlatformNode: AnyObject> {
    private unowned let parent: Context2<PlatformNode>? = nil 
    private let associatedComponent: (any UI2)? = nil

    fileprivate func isContainer() {

    }
}
