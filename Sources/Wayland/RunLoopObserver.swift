import CoreFoundation

public class RunLoopObserver {
    let observer: CFRunLoopObserver
    let runLoop: CFRunLoop

    public init(
        on activities: [CFRunLoopActivity],
        repeated: Bool = true,
        runLoop: CFRunLoop = CFRunLoopGetCurrent(),
        priority: Int = 0,
        _ callback: @escaping (CFRunLoopActivity) -> Void
    ) {
        self.runLoop = runLoop

        let activities = activities.reduce(CFOptionFlags()) { partialResult, activity in
            activity.rawValue | partialResult
        }

        observer = CFRunLoopObserverCreateWithHandler(
            nil, activities, repeated, priority
        ) { observer, activity in
            callback(activity)
        }!

        CFRunLoopAddObserver(runLoop, observer, kCFRunLoopDefaultMode)

    }

    deinit {
        CFRunLoopRemoveObserver(runLoop, observer, kCFRunLoopDefaultMode)
    }
}
