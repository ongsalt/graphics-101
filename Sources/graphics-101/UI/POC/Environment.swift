class Environment {
    nonisolated(unsafe) let current: Environment? = ComponentContext.current?.environment 

    // Stores values as 'Any', keyed by the unique ID of their Type
    private var storage: [ObjectIdentifier: [Any]] = [:]
    private(set) var parent: Environment? = nil

    init(parent: Environment? = nil) {
        self.parent = parent
    }

    func pop<T>() -> T? {
        let key = ObjectIdentifier(T.self)
        return storage[key, default: []].popLast() as! T?
    }

    func push<T>(_ value: T) {
        let key = ObjectIdentifier(T.self)
        storage[key, default: []].append(value)
    }

    func get<T>(_ type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        if let value = storage[key] {
            return value.last as! T?
        }

        return parent?.get(type) 
    }

    subscript<T>(_ type: T.Type) -> T {
        self.get(type)!
    }
}
