open class EffectScope {
    weak var parent: (EffectScope)?
    var children: [EffectScope] = []

    public init() {
        self.parent = TrackingContext.shared.currentEffectScope
        self.parent?.addChildren(effect: self)
    }


    convenience public init(_ fn: () -> Void) {
        self.init()
        self.run(fn)
    }

    func run(_ fn: () -> Void) {
        let previous =  TrackingContext.shared.currentEffectScope
        TrackingContext.shared.currentEffectScope = self
        
        fn()
        
        TrackingContext.shared.currentEffectScope = previous
    }

    func addChildren(effect: EffectScope) {
        self.children.append(effect)
    }

    public func destroy() {
        for c in children {
            c.destroy()
        }
    }
}
