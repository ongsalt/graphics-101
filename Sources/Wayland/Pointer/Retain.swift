struct Retained<T: AnyObject> {
    let instance: Unmanaged<T>

    init(_ value: T) {
        instance = Unmanaged.passRetained(value)
    }

    static func run<S>(fromPointer: UnsafeMutableRawPointer, _ block: (T) -> S) -> S {
        fromPointer.withMemoryRebound(to: Self.self, capacity: 1) { pointer in
            let this: Retained<T> = pointer.move()
            pointer.deallocate()

            return block(this.instance.takeRetainedValue())
        }
    }

    consuming func pointer() -> UnsafeMutablePointer<Self> {
        let pointer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        pointer.initialize(to: self)
        return pointer
    }
}
