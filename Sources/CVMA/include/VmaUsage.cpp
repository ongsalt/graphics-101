
#define VMA_STATIC_VULKAN_FUNCTIONS 0
#define VMA_DYNAMIC_VULKAN_FUNCTIONS 0

#define VMA_IMPLEMENTATION
#include "vk_mem_alloc.h"

/**
If you use volk library:

    Define VMA_STATIC_VULKAN_FUNCTIONS and VMA_DYNAMIC_VULKAN_FUNCTIONS to 0.
    Use function vmaImportVulkanFunctionsFromVolk() to fill in the structure
VmaVulkanFunctions. For more information, see the description of this function.
*/