struct Vulkan {
    static func makeVersion(major: UInt32, minor: UInt32, patch: UInt32) -> UInt32 {
        return (major << 22) | (minor << 12) | patch
    }

    static func makeApiVersion(variant: UInt32, major: UInt32, minor: UInt32, patch: UInt32) -> UInt32 {
        return (variant << 29) | (major << 22) | (minor << 12) | patch
    }

    static let apiVersion1_0 = makeApiVersion(variant: 0, major: 1, minor: 0, patch: 0)

}
