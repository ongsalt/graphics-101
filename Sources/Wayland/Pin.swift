class Pin<T> {
    public let ptr: UnsafeMutablePointer<T>

    init(_ value: T) {
        ptr = UnsafeMutablePointer.allocate(capacity: 1)
        ptr.initialize(to: value)
    }

    public var pointee: T {
        get {
            ptr.pointee
        }
        set {
            ptr.pointee = newValue
        }
    }

    // lmao
    func immortalize() {
        Unmanaged.passRetained(self).retain()
    }

    deinit {
        print("[Pin] wrapper for \(T.self) \(pointee) dropped")
        // ptr.deallocate()
    }
}
