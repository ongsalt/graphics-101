import CWayland
import Glibc

// content of a wl_surface
struct Buffer {
    let buffer: OpaquePointer

    init(pool: SHMPool, offset: Int32, width: Int32, height: Int32, stride: Int32, format: wl_shm_format) {
        buffer = wl_shm_pool_create_buffer(
            pool.pool, offset,
            width, height, stride, format.rawValue
        )!
    }

    func s() {
        
    }
}
