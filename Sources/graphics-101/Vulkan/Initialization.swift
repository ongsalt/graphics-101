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
    let appInfo = Box(
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

    let priority = Box(Float(1.0))

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

    let deviceFeatures = Box(VkPhysicalDeviceFeatures())
    deviceFeatures[].samplerAnisotropy = true

    let device = queueCreateInfos.withUnsafeBufferPointer { queueCreateInfos in
        let enabledVk12Features = Box(VkPhysicalDeviceVulkan12Features())
        enabledVk12Features[].sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
        enabledVk12Features[].descriptorIndexing = true
        enabledVk12Features[].descriptorBindingVariableDescriptorCount = true
        enabledVk12Features[].runtimeDescriptorArray = true
        enabledVk12Features[].bufferDeviceAddress = true

        let enabledVk13Features = Box(VkPhysicalDeviceVulkan13Features())
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
    let allocatorCreateInfo = Box(createZeroedStruct(of: VmaAllocatorCreateInfo.self))
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

    let vulkanFunctions = Box(VmaVulkanFunctions())
    vmaImportVulkanFunctionsFromVolk(allocatorCreateInfo.ptr, vulkanFunctions.ptr)

    allocatorCreateInfo[].pVulkanFunctions = vulkanFunctions.readonly

    var allocator: VmaAllocator? = VmaAllocator(bitPattern: 0)
    let res = vmaCreateAllocator(allocatorCreateInfo.ptr, &allocator)
    guard res.rawValue == 0 else {
        fatalError("createVMA failed with result: \(res)")
    }

    return allocator!
}

private func chooseSwapSurfaceFormat(from availableFormats: [VkSurfaceFormatKHR])
    -> VkSurfaceFormatKHR
{
    return availableFormats.first {
        $0.format == VK_FORMAT_B8G8R8A8_SRGB && $0.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
    } ?? availableFormats[0]
}

// TODO: allow vsync toggle
private func chooseSwapPresentMode(from availablePresentModes: [VkPresentModeKHR])
    -> VkPresentModeKHR
{
    return availablePresentModes.contains(VK_PRESENT_MODE_MAILBOX_KHR)
        ? VK_PRESENT_MODE_MAILBOX_KHR
        : VK_PRESENT_MODE_FIFO_KHR
}

private func chooseSwapExtent(capabilities: VkSurfaceCapabilitiesKHR, preferredSize: SIMD2<UInt32>)
    -> VkExtent2D
{
    if capabilities.currentExtent.width != UInt32.max {
        return capabilities.currentExtent
    }

    let width = preferredSize.x
    let height = preferredSize.y

    let actualExtent = VkExtent2D(
        width: width.clamp(
            to: capabilities.minImageExtent.width...capabilities.maxImageExtent.width),
        height: height.clamp(
            to: capabilities.minImageExtent.height...capabilities.maxImageExtent.height)
    )

    return actualExtent
}

private func createSwapChain(
    surface: VkSurfaceKHR,
    physicalDevice: VkPhysicalDevice,
    logicalDevice device: VkDevice,
    preferredSize: SIMD2<UInt32>,
    indices: SelectedQueuesIndices,
    oldSwapchain: VkSwapchainKHR? = nil
) -> (swapChain: VkSwapchainKHR, surfaceFormat: VkSurfaceFormatKHR, extent: VkExtent2D) {
    let supportDetails = SwapChainSupportDetails(
        physicalDevice: physicalDevice,
        surface: surface
    )

    let surfaceFormat = chooseSwapSurfaceFormat(from: supportDetails.formats)
    let presentMode = chooseSwapPresentMode(from: supportDetails.presentModes)
    let extent = chooseSwapExtent(
        capabilities: supportDetails.capabilities, preferredSize: preferredSize)

    // print(supportDetails.formats)
    let surfaceCaps = supportDetails.capabilities

    let queueFamilyIndices = [indices.graphicsFamily!, indices.presentFamily!].map { UInt32($0) }
    let swapChain = queueFamilyIndices.withUnsafeBufferPointer { queueFamilyIndices in
        let swapchainCI = Box(VkSwapchainCreateInfoKHR())
        swapchainCI[].sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapchainCI[].surface = surface
        swapchainCI[].minImageCount = surfaceCaps.minImageCount
        swapchainCI[].imageFormat = surfaceFormat.format
        swapchainCI[].imageColorSpace = surfaceFormat.colorSpace
        swapchainCI[].imageExtent = extent
        swapchainCI[].imageArrayLayers = 1
        swapchainCI[].imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue
        swapchainCI[].presentMode = presentMode

        swapchainCI[].preTransform = supportDetails.capabilities.currentTransform
        swapchainCI[].compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        swapchainCI[].clipped = true

        if indices.graphicsFamily != indices.presentFamily {
            swapchainCI[].imageSharingMode = VK_SHARING_MODE_CONCURRENT
            swapchainCI[].queueFamilyIndexCount = 2

            swapchainCI[].pQueueFamilyIndices = queueFamilyIndices.baseAddress
        } else {
            swapchainCI[].imageSharingMode = VK_SHARING_MODE_EXCLUSIVE
            swapchainCI[].queueFamilyIndexCount = 0  // Optional
            swapchainCI[].pQueueFamilyIndices = nil  // Optional
        }

        // TODO: specify this
        swapchainCI[].oldSwapchain = oldSwapchain

        var swapChain: VkSwapchainKHR? = VkSwapchainKHR(bitPattern: 0)
        vkCreateSwapchainKHR(device, swapchainCI.ptr, nil, &swapChain).expect(
            "Cannot create swapchain")

        return swapChain!
    }

    return (swapChain, surfaceFormat, extent)
}

func createImageViews(
    device: VkDevice, swapChainImages: [VkImage], swapChainSurfaceFormat: VkSurfaceFormatKHR
) -> [VkImageView] {
    var swapChainImageViews = Array(
        repeating: VkImageView(bitPattern: 0), count: swapChainImages.count)

    for (i, image) in swapChainImages.enumerated() {
        var createInfo = VkImageViewCreateInfo()
        createInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO
        createInfo.image = image
        createInfo.viewType = VK_IMAGE_VIEW_TYPE_2D
        createInfo.format = swapChainSurfaceFormat.format

        createInfo.components.r = VK_COMPONENT_SWIZZLE_IDENTITY
        createInfo.components.g = VK_COMPONENT_SWIZZLE_IDENTITY
        createInfo.components.b = VK_COMPONENT_SWIZZLE_IDENTITY
        createInfo.components.a = VK_COMPONENT_SWIZZLE_IDENTITY

        createInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
        createInfo.subresourceRange.baseMipLevel = 0
        createInfo.subresourceRange.levelCount = 1
        createInfo.subresourceRange.baseArrayLayer = 0
        createInfo.subresourceRange.layerCount = 1

        vkCreateImageView(device, &createInfo, nil, &swapChainImageViews[i]).expect(
            "Cannot create image view")
    }

    return swapChainImageViews.map { $0! }
}

private func createGraphicsPipeline(device: VkDevice, swapChainExtent: VkExtent2D, surfaceFormat: VkSurfaceFormatKHR) {
    let shader = try! Shader(filename: "triangle", device: device)

    var vertCi = VkPipelineShaderStageCreateInfo()
    vertCi.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
    vertCi.stage = VK_SHADER_STAGE_VERTEX_BIT
    vertCi.module = shader.shaderModule
    let vertName = CString("vtx_main")
    vertCi.pName = vertName.ptr

    var fragCi = VkPipelineShaderStageCreateInfo()
    fragCi.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
    fragCi.stage = VK_SHADER_STAGE_FRAGMENT_BIT
    fragCi.module = shader.shaderModule
    let fragName = CString("frag_main")
    fragCi.pName = fragName.ptr

    let shaderStages = [vertCi, fragCi]

    let vertexInputCI = Box(VkPipelineVertexInputStateCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
        // $0.vertexBindingDescriptionCount = 0
        // $0.pVertexBindingDescriptions = nil  // Optional
        // $0.vertexAttributeDescriptionCount = 0
        // $0.pVertexAttributeDescriptions = nil  // Optional
    }

    let inputAssemblyCI = Box(VkPipelineInputAssemblyStateCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
        $0.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
        $0.primitiveRestartEnable = false
    }

    let viewport = Box(
        VkViewport(
            x: 0,
            y: 0,
            width: Float(swapChainExtent.width),
            height: Float(swapChainExtent.height),
            minDepth: 0,
            maxDepth: 1
        ))

    let scissor = Box(
        VkRect2D(
            offset: VkOffset2D(x: 0, y: 0),
            extent: swapChainExtent
        ))

    let viewportCI = Box(VkPipelineViewportStateCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
        $0.viewportCount = 1
        $0.pViewports = viewport.readonly
        $0.scissorCount = 1
        $0.pScissors = scissor.readonly
    }

    let multisampleCI = Box(VkPipelineMultisampleStateCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
        $0.sampleShadingEnable = false
        // $0.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT
        $0.rasterizationSamples = VK_SAMPLE_COUNT_4_BIT
        $0.minSampleShading = 1.0  // Optional
        $0.pSampleMask = nil  // Optional
        $0.alphaToCoverageEnable = false  // Optional
        $0.alphaToOneEnable = false  // Optional
    }

    let rasterizationCI = Box(VkPipelineRasterizationStateCreateInfo()) { rasterizer in
        rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
        rasterizer.depthClampEnable = false
        rasterizer.polygonMode = VK_POLYGON_MODE_FILL
        rasterizer.lineWidth = 1.0

        // rasterizer.cullMode = VK_CULL_MODE_BACK_BIT.rawValue
        // rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE

        // rasterizer.depthBiasEnable = false
        // rasterizer.depthBiasConstantFactor = 0.0  // Optional
        // rasterizer.depthBiasClamp = 0.0  // Optional
        // rasterizer.depthBiasSlopeFactor = 0.0  // Optional
    }

    let pushConstantRange = Box(VkPushConstantRange()) {
        $0.stageFlags = VK_SHADER_STAGE_VERTEX_BIT.rawValue
        $0.size = UInt32(MemoryLayout<VkDeviceAddress>.size)
    }

    let colorBlendAttachment = Box(VkPipelineColorBlendAttachmentState()) {
        $0.colorWriteMask = VkColorComponentFlags(
            VK_COLOR_COMPONENT_R_BIT.rawValue | VK_COLOR_COMPONENT_G_BIT.rawValue
                | VK_COLOR_COMPONENT_B_BIT.rawValue | VK_COLOR_COMPONENT_A_BIT.rawValue
        )
        $0.blendEnable = true
        $0.srcColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
        $0.dstColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA
        $0.colorBlendOp = VK_BLEND_OP_ADD
        $0.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE
        // $0.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO
        $0.dstAlphaBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
        $0.alphaBlendOp = VK_BLEND_OP_ADD
    }

    let colorBlendingCI = Box(VkPipelineColorBlendStateCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
        $0.logicOpEnable = false
        $0.logicOp = VK_LOGIC_OP_COPY
        $0.attachmentCount = 1
        $0.pAttachments = colorBlendAttachment.readonly
        $0.blendConstants.0 = 0.0
        $0.blendConstants.1 = 0.0
        $0.blendConstants.2 = 0.0
        $0.blendConstants.3 = 0.0
    }

    let pipelineLayoutCI = Box(
        VkPipelineLayoutCreateInfo(
            sType: VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            pNext: nil,
            flags: VkPipelineLayoutCreateFlags(),
            setLayoutCount: 0,
            pSetLayouts: nil,
            pushConstantRangeCount: 1,
            pPushConstantRanges: pushConstantRange.ptr
        ))

    let pipelineLayout = with(VkPipelineLayout(bitPattern: 0)) {
        vkCreatePipelineLayout(device, pipelineLayoutCI.ptr, nil, &$0).expect(
            "Cannot create pipeline layout")
    }

    let imageFormat = Box(surfaceFormat.format)
    // Dynamic rendering
    let renderingCI = Box(VkPipelineRenderingCreateInfo()) {
        $0.sType = VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO
        $0.colorAttachmentCount = 1
        $0.pColorAttachmentFormats = imageFormat.readonly
        // $0.depthAttachmentFormat = depthFormat
    }

    shaderStages.withUnsafeBufferPointer { shaderStages in
        var pipelineCI = with(VkGraphicsPipelineCreateInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
            $0.pNext = renderingCI.raw
            $0.layout = pipelineLayout!

            $0.stageCount = UInt32(shaderStages.count)
            $0.pStages = shaderStages.baseAddress
            $0.pVertexInputState = vertexInputCI.readonly
            $0.pInputAssemblyState = inputAssemblyCI.readonly
            $0.pMultisampleState = multisampleCI.readonly
            $0.pColorBlendState = colorBlendingCI.readonly
            $0.pRasterizationState = rasterizationCI.readonly
            $0.pViewportState = viewportCI.readonly
        }

        let pipeline = with(VkPipeline(bitPattern: 0)) {
            vkCreateGraphicsPipelines(device, nil, 1, &pipelineCI, nil, &$0).expect(
                "Cannot create pipeline")
        }!
    }
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

    var swapChainSurfaceFormat: VkSurfaceFormatKHR
    var swapChain: VkSwapchainKHR
    var swapChainExtent: VkExtent2D
    var swapChainImages: [VkImage]
    var swapChainImageViews: [VkImageView]

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

        let (swapChain, swapChainSurfaceFormat, extent) = createSwapChain(
            surface: surface,
            physicalDevice: physicalDevice,
            logicalDevice: device,
            preferredSize: SIMD2(800, 600),
            indices: families
        )

        self.swapChain = swapChain
        self.swapChainSurfaceFormat = swapChainSurfaceFormat
        self.swapChainExtent = extent

        swapChainImages = Vulkan.getArray(of: VkImage?.self) { [device, swapChain] count, arr in
            vkGetSwapchainImagesKHR(device, swapChain, count, arr)
        }.unwrapPointer()

        swapChainImageViews = createImageViews(
            device: device, swapChainImages: swapChainImages,
            swapChainSurfaceFormat: swapChainSurfaceFormat)

        createGraphicsPipeline(
            device: device,
            swapChainExtent: extent,
            surfaceFormat: swapChainSurfaceFormat
        )
    }

    func resize(to: SIMD2<UInt32>) {
        let c = createSwapChain(
            surface: surface,
            physicalDevice: physicalDevice,
            logicalDevice: device,
            preferredSize: SIMD2(800, 600),
            indices: families,
            oldSwapchain: swapChain
        )

        self.swapChain = c.swapChain
        self.swapChainSurfaceFormat = c.surfaceFormat
    }

    consuming func destroy() {
        vkDestroySwapchainKHR(device, swapChain, nil)
        vkDestroySurfaceKHR(instance, surface, nil)
        vkDestroyDevice(device, nil)
        vkDestroyInstance(instance, nil)
    }

    deinit {
        // TODO: wait for idle
        destroy()
    }
}
