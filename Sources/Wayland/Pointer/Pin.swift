public class Pin<T> {
    public let ptr: UnsafeMutablePointer<T>
    public var readonly: UnsafePointer<T> {
        UnsafePointer(ptr)
    }
    public let opaque: OpaquePointer

    public init(_ value: T) {
        ptr = UnsafeMutablePointer.allocate(capacity: 1)
        ptr.initialize(to: value)

        opaque = OpaquePointer(ptr)
    }

    public convenience init(leaking value: T) {
        self.init(value)
        self.leak()
    }

    public convenience init(zeroedStructOf type: T.Type) {
        self.init(createZeroedStruct(of: type))
    }

    public var pointee: T {
        get {
            ptr.pointee
        }
        _modify {
            yield &ptr.pointee
        }
        set {
            ptr.pointee = newValue
        }
    }

    public subscript() -> T {
        get {
            ptr.pointee
        }
        _modify {
            yield &ptr.pointee
        }
        set {
            ptr.pointee = newValue
        }
    }

    // lmao
    @discardableResult
    public func leak() -> Pin<T> {
        Unmanaged.passRetained(self)

        return self
    }

    deinit {
        ptr.deinitialize(count: 1)
        ptr.deallocate()
        // print("[Pin] wrapper for \(T.self) \(pointee) dropped")
    }
}
