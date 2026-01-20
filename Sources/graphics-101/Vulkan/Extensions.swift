import CVulkan

extension VkBool32: @retroactive ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = if value {
            1
        } else {
            0
        }
    }

    public typealias BooleanLiteralType = Bool
}

extension VkBool32 {
    func isTrue() -> Bool {
        self == 1
    }
}