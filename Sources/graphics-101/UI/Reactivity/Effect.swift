import Dispatch
import Foundation
@_spi(SwiftUI) import Observation

// effect scope own it

// its in its parent isolation context
// its not safe tho
public final class Effect: @unchecked Sendable {
    private let tags: [String]?
    let fn: () -> Void

    var stopped: Bool = false

    @discardableResult
    public init(tags: [String]? = nil, _ fn: @escaping () -> Void) {
        self.tags = tags
        self.fn = fn

        self.update()
    }

    func destroy() {
        stopped = true
    }

    func update() {
        // TrackingContext.shared.currentEffectScope = self

        withObservationTracking {
            self.fn()
        } didSet: { [weak self] tracking in
            tracking.cancel()

            // switch back to current thread somehow
            if let self = self {
                if !self.stopped {
                    self.update()
                }
            } else {
                print("effect owner is not yet implemented")
            }
        }

    }
}
