import Observation

@Observable
public final class Signal<T>: Source {
    public var value: T

    public init(_ value: T) {
        // self.innerValue = Box(value)
        self.value = value
    }

    func toReadOnly() -> ReadOnlySignal<T> {
        Computed { self.value }
    }
}
