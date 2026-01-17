// just put this onto heap
public class Box<T> {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}
