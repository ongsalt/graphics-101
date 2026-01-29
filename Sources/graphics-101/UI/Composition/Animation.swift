enum AnimationStatus {
    case ongoing
    case done
}
typealias AnimationCallback = (ContinuousClock.Duration) -> AnimationStatus?

struct AnimationFrameRequest {
    let callback: (ContinuousClock.Duration) -> AnimationStatus?
    let createdAt: ContinuousClock.Instant

    func run() -> AnimationStatus? {
        callback(createdAt.duration(to: .now))
    }
}
