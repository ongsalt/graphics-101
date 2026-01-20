import CVulkan

struct Vulkan {
    static func makeVersion(major: UInt32, minor: UInt32, patch: UInt32) -> UInt32 {
        return (major << 22) | (minor << 12) | patch
    }

    static func makeApiVersion(variant: UInt32, major: UInt32, minor: UInt32, patch: UInt32)
        -> UInt32
    {
        return (variant << 29) | (major << 22) | (minor << 12) | patch
    }

    static let apiVersion1_0 = makeApiVersion(variant: 0, major: 1, minor: 0, patch: 0)

    static func printAvailableExtension() {
        var count: UInt32 = 0
        vkEnumerateInstanceExtensionProperties(nil, &count, nil)

        var extensions = Array(
            repeating: VkExtensionProperties(), count: Int(count))
        vkEnumerateInstanceExtensionProperties(nil, &count, &extensions)

        for var p in extensions {
            let name = String(cStringPointer: &p)
            print(name)
        }
    }

    static func printAvailableLayers() {
        var count: UInt32 = 0
        vkEnumerateInstanceLayerProperties(&count, nil)

        var extensions = Array(
            repeating: VkLayerProperties(), count: Int(count))
        vkEnumerateInstanceLayerProperties(&count, &extensions)

        for var p in extensions {
            let name = String(cStringPointer: &p)
            print(name)
        }
    }

}

struct SwapChainSupportDetails {
    let capabilities: VkSurfaceCapabilitiesKHR
    let formats: [VkSurfaceFormatKHR]
    let presentModes: [VkPresentModeKHR]

    init(querying device: VkDevice, surface: VkSurfaceKHR) {
        var capabilities = VkSurfaceCapabilitiesKHR()
        vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &capabilities)

        var formatCount: UInt32 = 0
        vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &formatCount, nil)
        var formats = Array(repeating: VkSurfaceFormatKHR(), count: Int(formatCount))
        vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, nil, &formats)

        var presentModesCounts: UInt32 = 0
        vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &presentModesCounts, nil)
        var presentModes = Array(repeating: VkPresentModeKHR(0), count: Int(presentModesCounts))
        vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, nil, &presentModes)

        self.capabilities = capabilities
        self.formats = formats
        self.presentModes = presentModes
    }
}
