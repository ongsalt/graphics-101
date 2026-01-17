public class Pin<T> {
    public let ptr: UnsafeMutablePointer<T>
    public let opaque: OpaquePointer

    public init(_ value: T) {
        ptr = UnsafeMutablePointer.allocate(capacity: 1)
        ptr.initialize(to: value)

        opaque = OpaquePointer(ptr) 
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
    public func immortalize() {
        Unmanaged.passRetained(self).retain().retain()
    }
 
    deinit {
        ptr.deinitialize(count: 1)
        ptr.deallocate()
        // print("[Pin] wrapper for \(T.self) \(pointee) dropped")
    }
}
