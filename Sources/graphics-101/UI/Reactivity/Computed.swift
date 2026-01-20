import Observation


public class Computed<T>: EffectScope, Source, Subscriber {
    private let tags: [String]?
    let fn: () -> T

    private var dirty = true

    private lazy var innerValue: T = compute()
    public var value: T {
        if dirty {
            innerValue = compute()
            dirty = false
        }
        return innerValue
    }

    public init(tags: [String]? = nil, _ fn: @escaping () -> T) {
        self.tags = tags
        self.fn = fn
        super.init()
    }

    override public func destroy() {

        super.destroy()
    }

    func update() {
        self.dirty = true
        // TODO: detect change for T: Eq
    }

    func compute() -> T {
        let previousScope: EffectScope? = TrackingContext.shared.currentEffectScope
        TrackingContext.shared.currentEffectScope = self

        defer {
            TrackingContext.shared.currentEffectScope = previousScope
        }
        
        return self.fn()
    }
}


