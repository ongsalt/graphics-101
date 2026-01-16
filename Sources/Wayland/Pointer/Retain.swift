// This is ass api
// TODO: redesign it
class Retained<T: AnyObject> {
    let instance: Unmanaged<T>

    init(_ value: T) {
        instance = Unmanaged.passRetained(value)
    }

    static func run<S>(fromPointer: UnsafeMutableRawPointer, once: Bool = false, _ block: (T) -> S)
        -> S
    {
        fromPointer.withMemoryRebound(to: Unmanaged<T>.self, capacity: 1) { pointer in
            let this: Unmanaged<T> = pointer.move()
            // Memory leak is memory safe
            let value =
                if once { this.takeRetainedValue() } else {
                    this.takeUnretainedValue()
                }

            return block(value)
            // return block(this.instance.takeUnretainedValue())
        }
    }

    func pointer() -> UnsafeMutablePointer<Unmanaged<T>> {
        let pointer = UnsafeMutablePointer<Unmanaged<T>>.allocate(capacity: 1)
        pointer.initialize(to: self.instance)
        return pointer
    }

    consuming func stop() {
        instance.takeRetainedValue()
    }

}
