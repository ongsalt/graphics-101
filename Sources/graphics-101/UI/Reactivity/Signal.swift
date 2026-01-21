import Observation

@Observable
public final class Signal<T>: Source {
    public var value: T

    public init(_ value: T) {
        // self.innerValue = Box(value)
        self.value = value
    }

    public func update(map: (T) -> T) {
        self.value = map(self.value)
    }

    func toReadOnly() -> ReadOnlyBinding<T> {
        ReadOnlyBinding(self.value)
    }

    deinit {
        print("Deinit Signal: \(value)")
    }
}
