import CWayland
import Glibc

struct SHMPool {
    let pool: OpaquePointer
    let poolData: UnsafeMutableRawPointer

    init(shm: SharedMemoryBuffer, fd: Int32, size: Int32) {
        poolData = mmap(nil, Int(size), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)!
        pool = wl_shm_create_pool(shm.shm, fd, size)!
    }

    func createBuffer(offset: Int32, width: Int32, height: Int32, stride: Int32, format: wl_shm_format)
        -> Buffer
    {
        Buffer(
            pool: self, offset: offset, width: width, height: height, stride: stride, format: format
        )
    }

    // 4 bytes????
    // TODO:
    subscript(offset: UInt32) -> UInt32 {
        get {
            poolData.load(fromByteOffset: Int(offset), as: UInt32.self)
        }
        set {
            poolData.storeBytes(of: newValue, toByteOffset: Int(offset), as: UInt32.self)
        }
    }
}
