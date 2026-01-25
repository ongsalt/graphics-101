@preconcurrency import CVMA
import Foundation
import Wayland

class GPUBuffer<BufferData> {
    let mapped: UnsafeMutableBufferPointer<BufferData>
    private let vmaAllocator: VmaAllocator
    private let vmaAllocation: VmaAllocation
    // this is to please the ffi
    var buffer: VkBuffer?

    var count: Int {
        mapped.count
    }

    // we should pass usages too
    convenience init(data: [BufferData], allocator: VmaAllocator, device: VkDevice, count: Int? = nil) {
        self.init(of: BufferData.self, allocator: allocator, device: device, count: count ?? data.count)

        self.mapped.initialize(from: data)
    }

    // Create this per frame in flight
    // TODO: resize it
    init(of: BufferData.Type, allocator: VmaAllocator, device: VkDevice, count: Int? = nil) {
        // well, its ~11 f32 -> ~ 64 byte each * 1000 vertex = 64Kb
        // fuck, just do 1mb
        let count = count ?? ((1024 * 1024) / MemoryLayout<BufferData>.size)
        let size = count * MemoryLayout<BufferData>.size

        var bufferCI = VkBufferCreateInfo(
            sType: VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
            pNext: nil,
            flags: 0,
            size: UInt64(size),
            usage: VK_BUFFER_USAGE_VERTEX_BUFFER_BIT.rawValue | VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT.rawValue,
            sharingMode: VK_SHARING_MODE_EXCLUSIVE,
            queueFamilyIndexCount: 0,
            pQueueFamilyIndices: nil
        )

        var bufferAllocCI = VmaAllocationCreateInfo(
            flags: VMA_ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT.rawValue
                | VMA_ALLOCATION_CREATE_HOST_ACCESS_ALLOW_TRANSFER_INSTEAD_BIT.rawValue
                | VMA_ALLOCATION_CREATE_MAPPED_BIT.rawValue,
            usage: VMA_MEMORY_USAGE_AUTO,
            requiredFlags: 0,
            preferredFlags: 0,
            memoryTypeBits: 0,
            pool: nil,
            pUserData: nil,
            priority: 0
        )

        var buffer: VkBuffer?
        var mapped: UnsafeMutableRawPointer?
        var allocation: VmaAllocation?

        vmaCreateBuffer(allocator, &bufferCI, &bufferAllocCI, &buffer, &allocation, nil).expect(
            "failed to create vertex buffer")
        vmaMapMemory(allocator, allocation!, &mapped).expect("Failed to map memory")

        // now we can write to
        let swiftBuffer = UnsafeMutableBufferPointer(
            start: mapped!.assumingMemoryBound(to: BufferData.self), count: count)

        self.mapped = swiftBuffer
        self.buffer = buffer!
        self.vmaAllocation = allocation!
        self.vmaAllocator = allocator
    }

    deinit {
        vmaUnmapMemory(vmaAllocator, vmaAllocation)
        vmaDestroyBuffer(vmaAllocator, buffer, vmaAllocation)
    }

}
