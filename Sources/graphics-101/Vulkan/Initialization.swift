@preconcurrency import CVMA
import Glibc
import Wayland

private let instanceLayers = CStringArray {
    #if DEBUG
        "VK_LAYER_KHRONOS_validation"
    #endif
}
private let instanceExtensions: CStringArray = [
    "VK_KHR_get_physical_device_properties2",
    "VK_KHR_external_fence_capabilities",
    "VK_KHR_surface",
    "VK_KHR_wayland_surface",
]

private let deviceLayers: CStringArray = []
private let deviceExtensions: CStringArray = [
    "VK_KHR_swapchain",
    "VK_KHR_external_fence",
    "VK_KHR_external_fence_fd",
]

private func createInstance() -> VkInstance {
    volkInitialize()
    var instance: VkInstance! = VkInstance(bitPattern: 0)

    // how long should this be alive tho
    let appInfo = Pin(
        VkApplicationInfo(
            sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
            pNext: nil,
            pApplicationName: "yomum".persist(),
            applicationVersion: Vulkan.makeVersion(major: 1, minor: 0, patch: 0),
            pEngineName: "yomum engine".persist(),
            engineVersion: Vulkan.makeVersion(major: 1, minor: 0, patch: 0),
            apiVersion: Vulkan.apiVersion
        )
    )

    // TODO: check for availability
    // print(instanceLayers.ptr)
    // print(instanceExtensions.ptr)
    var createInfo = VkInstanceCreateInfo(
        sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        pNext: nil,
        flags: VkInstanceCreateFlags(),
        pApplicationInfo: appInfo.readonly,

        enabledLayerCount: instanceLayers.count,
        ppEnabledLayerNames: instanceLayers.ptr,

        // FIXME: add more extension when it complain
        enabledExtensionCount: instanceExtensions.count,
        ppEnabledExtensionNames: instanceExtensions.ptr
    )

    // var allocationCallback = VkAllocationCallbacks(
    //     pUserData: UnsafeMutableRawPointer!,
    //     pfnAllocation: (UnsafeMutableRawPointer?, Int, Int, VkSystemAllocationScope) -> UnsafeMutableRawPointer?, pfnReallocation: (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int, Int, VkSystemAllocationScope) -> UnsafeMutableRawPointer?, pfnFree: (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void, pfnInternalAllocation: (UnsafeMutableRawPointer?, Int, VkInternalAllocationType, VkSystemAllocationScope) -> Void, pfnInternalFree: (UnsafeMutableRawPointer?, Int, VkInternalAllocationType, VkSystemAllocationScope) -> Void
    // )

    let result = vkCreateInstance(&createInfo, nil, &instance)
    guard result.rawValue == 0 else {
        fatalError(
            "Cannot create vulkan instance [code: \(result)] pls see https://docs.vulkan.org/refpages/latest/refpages/source/VkResult.html"
        )
    }

    volkLoadInstance(instance)

    // print("result \(result), instance: \(instance)")

    return instance
}

private func createWaylandSurface(
    instance: VkInstance, waylandDisplay: Wayland.Display, waylandSurface: Wayland.Surface
) -> VkSurfaceKHR {
    var createInfo = VkWaylandSurfaceCreateInfoKHR(
        sType: VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR,
        pNext: nil,
        flags: VkWaylandSurfaceCreateFlagsKHR(),
        display: waylandDisplay.display,
        surface: waylandSurface.surface
    )

    var surface: VkSurfaceKHR? = nil

    vkCreateWaylandSurfaceKHR(
        instance,
        &createInfo,
        nil,
        &surface
    )

    return surface!
}

// TODO: device picking logic: checkDeviceExtensionSupport
private func pickPhysicalDevice(instance: VkInstance) -> VkPhysicalDevice {
    var count: UInt32 = 0
    vkEnumeratePhysicalDevices(instance, &count, nil)

    var devices: [VkPhysicalDevice?] = Array(
        repeating: nil, count: Int(count))
    vkEnumeratePhysicalDevices(instance, &count, &devices)

    for device in devices {
        var properties = VkPhysicalDeviceProperties()
        vkGetPhysicalDeviceProperties(device, &properties)

        var deviceFeatures = VkPhysicalDeviceFeatures()
        vkGetPhysicalDeviceFeatures(device, &deviceFeatures)

        // let name = String(cStringPointer: &properties.deviceName)
        // print(name)
        // print(deviceFeatures)
    }

    return devices[0]!

}

struct SelectedQueuesIndices {
    let graphicsFamily: Int?
    let presentFamily: Int?

    var uniqueCount: Int {
        let s: Set<Int?> = [graphicsFamily, presentFamily]
        return s.count
    }
}

private func findQueueFamilies(device: VkPhysicalDevice, surface: VkSurfaceKHR)
    -> SelectedQueuesIndices
{
    var count: UInt32 = 0
    vkGetPhysicalDeviceQueueFamilyProperties(device, &count, nil)

    var queues = Array(
        repeating: VkQueueFamilyProperties(), count: Int(count))
    vkGetPhysicalDeviceQueueFamilyProperties(device, &count, &queues)

    let graphicsFamily = queues.firstIndex {
        $0.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue != 0
    }!

    var presentFamily: Int? = nil
    var supportPresentation: VkBool32 = false
    vkGetPhysicalDeviceSurfaceSupportKHR(
        device, UInt32(graphicsFamily), surface, &supportPresentation)
    if supportPresentation.isTrue() {
        presentFamily = graphicsFamily
    }

    return SelectedQueuesIndices(
        graphicsFamily: graphicsFamily,
        presentFamily: presentFamily
    )
}

private func createLogicalDevice(families: SelectedQueuesIndices, physicalDevice: VkPhysicalDevice)
    -> (device: VkDevice, graphicsQueue: VkQueue, presentQueue: VkQueue)
{

    let priority = Pin(Float(1.0))

    let queueCreateInfos = Array(
        repeating: VkDeviceQueueCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            pNext: nil,
            flags: VkDeviceQueueCreateFlags(),
            queueFamilyIndex: UInt32(families.graphicsFamily!),
            queueCount: 1,
            pQueuePriorities: priority.ptr
        ),
        count: families.uniqueCount
    )

    let deviceFeatures = Pin(VkPhysicalDeviceFeatures())
    deviceFeatures[].samplerAnisotropy = true

    let device = queueCreateInfos.withUnsafeBufferPointer { queueCreateInfos in
        let enabledVk12Features = Pin(VkPhysicalDeviceVulkan12Features())
        enabledVk12Features[].sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
        enabledVk12Features[].descriptorIndexing = true
        enabledVk12Features[].descriptorBindingVariableDescriptorCount = true
        enabledVk12Features[].runtimeDescriptorArray = true
        enabledVk12Features[].bufferDeviceAddress = true

        let enabledVk13Features = Pin(VkPhysicalDeviceVulkan13Features())
        enabledVk13Features[].sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES
        enabledVk13Features[].pNext = UnsafeMutableRawPointer(enabledVk12Features.opaque)
        enabledVk13Features[].synchronization2 = true
        enabledVk13Features[].dynamicRendering = true

        var deviceCreateInfo = VkDeviceCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            pNext: enabledVk13Features.ptr,
            flags: VkDeviceCreateFlags(),
            queueCreateInfoCount: 1,
            pQueueCreateInfos: queueCreateInfos.baseAddress,
            enabledLayerCount: deviceLayers.count,
            ppEnabledLayerNames: deviceLayers.ptr,
            enabledExtensionCount: deviceExtensions.count,
            ppEnabledExtensionNames: deviceExtensions.ptr,
            pEnabledFeatures: deviceFeatures.ptr
        )

        var device: VkDevice? = nil
        let result = vkCreateDevice(physicalDevice, &deviceCreateInfo, nil, &device)
        guard result.rawValue == 0 else {
            fatalError(
                "Can't create vulkan device [code: \(result)] pls see https://docs.vulkan.org/refpages/latest/refpages/source/VkResult.html"
            )
        }

        return device!

    }

    var graphicsQueue: VkQueue? = nil
    var presentQueue: VkQueue? = nil
    vkGetDeviceQueue(device, UInt32(families.graphicsFamily!), 0, &graphicsQueue)
    vkGetDeviceQueue(device, UInt32(families.presentFamily!), 0, &presentQueue)

    return (
        device: device,
        graphicsQueue: graphicsQueue!,
        presentQueue: presentQueue!
    )
}

private func createVMA(
    instance: VkInstance,
    physicalDevice: VkPhysicalDevice,
    logicalDevice: VkDevice,
) -> VmaAllocator {
    let allocatorCreateInfo = Pin(createZeroedStruct(of: VmaAllocatorCreateInfo.self))
    allocatorCreateInfo[].physicalDevice = physicalDevice
    allocatorCreateInfo[].device = logicalDevice
    allocatorCreateInfo[].instance = instance
    allocatorCreateInfo[].vulkanApiVersion = Vulkan.apiVersion
    allocatorCreateInfo[].flags =
        VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT.rawValue
        | VMA_ALLOCATOR_CREATE_EXT_MEMORY_PRIORITY_BIT.rawValue
    #if os(Windows)
        allocatorCreateInfo[].flags |= VMA_ALLOCATOR_CREATE_KHR_EXTERNAL_MEMORY_WIN32_BIT.rawValue
    #endif

    let vulkanFunctions = Pin(VmaVulkanFunctions())
    vmaImportVulkanFunctionsFromVolk(allocatorCreateInfo.ptr, vulkanFunctions.ptr)

    allocatorCreateInfo[].pVulkanFunctions = vulkanFunctions.readonly

    var allocator: VmaAllocator? = VmaAllocator(bitPattern: 0)
    let res = vmaCreateAllocator(allocatorCreateInfo.ptr, &allocator)
    guard res.rawValue == 0 else {
        fatalError("createVMA failed with result: \(res)")
    }

    return allocator!
}

private func createSwapChain(
    surface: VkSurfaceKHR,
    physicalDevice device: VkPhysicalDevice
) {
    let swapchainCI = Pin(VkSwapchainCreateInfoKHR())

    let supportDetails = SwapChainSupportDetails(
        physicalDevice: device, 
        surface: surface
    )

    print(supportDetails.formats)
    let surfaceCaps = supportDetails.capabilities

    let imageFormat = VkFormat(VK_FORMAT_B8G8R8A8_SRGB.rawValue)

    swapchainCI[].sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
    swapchainCI[].surface = surface
    swapchainCI[].minImageCount = surfaceCaps.minImageCount
    swapchainCI[].imageFormat = imageFormat
    swapchainCI[].imageColorSpace = VK_COLORSPACE_SRGB_NONLINEAR_KHR
    swapchainCI[].imageExtent = VkExtent2D(
        width: surfaceCaps.currentExtent.width,
        height: surfaceCaps.currentExtent.height
    )
    swapchainCI[].imageArrayLayers = 1
    swapchainCI[].imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
    swapchainCI[].preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
    swapchainCI[].compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    swapchainCI[].presentMode = VK_PRESENT_MODE_FIFO_KHR
}

class VulkanState {
    let instance: VkInstance
    let surface: VkSurfaceKHR
    let physicalDevice: VkPhysicalDevice
    let device: VkDevice

    let families: SelectedQueuesIndices
    let graphicsQueue: VkQueue
    let presentQueue: VkQueue

    let allocator: VmaAllocator

    init(waylandDisplay: Display, waylandSurface: Surface) {
        instance = createInstance()
        surface = createWaylandSurface(
            instance: instance, waylandDisplay: waylandDisplay, waylandSurface: waylandSurface)

        // TODO: setup debug messaging
        physicalDevice = pickPhysicalDevice(instance: instance)

        families = findQueueFamilies(device: physicalDevice, surface: surface)
        let c = createLogicalDevice(families: families, physicalDevice: physicalDevice)
        self.graphicsQueue = c.graphicsQueue
        self.presentQueue = c.presentQueue
        self.device = c.device

        allocator = createVMA(
            instance: instance, physicalDevice: physicalDevice, logicalDevice: device)


        createSwapChain(surface: surface, physicalDevice: physicalDevice)
    }

    deinit {
        vkDestroySurfaceKHR(instance, surface, nil)
        vkDestroyDevice(device, nil)
        vkDestroyInstance(instance, nil)
    }
}
