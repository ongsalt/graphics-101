import CWayland
import Foundation
import Glibc

struct SharedMemoryBuffer {
    let shm: OpaquePointer
    let fd: Int32
    let size: UInt

    init(shm: OpaquePointer, size: UInt) {
        self.shm = shm
        self.size = size
        
        let name = "/wl_shm-\(UUID())"

        fd = shm_open(name, O_RDWR | O_CREAT | O_EXCL, 0600)
        shm_unlink(name)

        // print("fd: \(fd)")

        var ret: Int32 = 0
        repeat {
            ret = ftruncate(fd, Int(size))
        } while errno == EINTR && ret < 0
    }

    func createPool() -> SHMPool {
        return SHMPool(shm: self, fd: fd, size: Int32(size))
    }
}
