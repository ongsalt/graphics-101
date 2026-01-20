class TrackingContext {
    // FIXME: well this is not threadsafe since the beginning, maybe i'll think about this
    nonisolated(unsafe) static let shared: TrackingContext = TrackingContext()
    // TODO: thread local context

    var currentEffectScope: EffectScope?
}