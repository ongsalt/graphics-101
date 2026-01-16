import CWayland
import Foundation
import Glibc

struct Window {

}

public enum InitWaylandError: Error {
    case noXdgRuntimeDirectory
    case cannotOpenSocket
    case cannotConnect
}

func wtf() throws(InitWaylandError) -> Int32 {
    guard let xdgRuntimeDirectory = ProcessInfo.processInfo.environment["XDG_RUNTIME_DIR"] else {
        throw .noXdgRuntimeDirectory
    }

    let waylandDisplay = ProcessInfo.processInfo.environment["WAYLAND_DISPLAY"] ?? "wayland-0"

    let waylandPath = "\(xdgRuntimeDirectory)/\(waylandDisplay)"

    var addr = sockaddr_un()
    addr.sun_family = UInt16(AF_UNIX)
    withUnsafeMutableBytes(of: &addr.sun_path) { ptr in
        ptr.copyBytes(from: waylandPath.utf8)
        ptr[waylandPath.count] = 0  // null terminated
    }

    let fd = socket(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0)
    guard fd != -1 else {
        throw .cannotOpenSocket
    }

    let c = withUnsafePointer(to: &addr) { ptr in
        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1, ) { ptr in
            connect(fd, ptr, UInt32(MemoryLayout<sockaddr_un>.size))
        }
    }

    guard c != -1 else {
        throw .cannotConnect
    }

    return fd
}

public struct State {
    var compositor: OpaquePointer!
    var sharedMemoryBuffer: OpaquePointer!
}

public struct Connection {
    let state: State

    public init() throws(InitWaylandError) {
        let waylandDisplay = ProcessInfo.processInfo.environment["WAYLAND_DISPLAY"] ?? "wayland-0"

        guard let display = wl_display_connect(waylandDisplay) else {
            throw .cannotConnect
        }

        let registry = wl_display_get_registry(display)!

        // this must be valid until connection is dropped
        let state = Pin(State())
        state.immortalize()

        // too
        let listener = Pin(wl_registry_listener())
        listener.immortalize()
        listener.pointee.global = { _, _, name, _, _ in
            print("global: \(name)")
        }
        listener.pointee.global = listenerCallback
        listener.pointee.global_remove = { _, _, _ in
            print("removed")
        }

        wl_registry_add_listener(registry, listener.ptr, UnsafeMutableRawPointer(state.ptr))
        wl_display_roundtrip(display)

        // print(state.pointee)
        self.state = state.pointee
        // print(self.state)

        // let w: Int32 = 640
        // let h: Int32 = 480
        // let size = w * h * 4 * 2

        let surface = wl_compositor_create_surface(self.state.compositor!)
        print("surface: \(surface)")
        // // sleep(1)

        // let shm = SharedMemoryBuffer(shm: self.state.sharedMemoryBuffer, size: UInt(size))
        // let pool = shm.createPool()
        // let buffer = pool.createBuffer(
        //     offset: 0, width: w, height: h, stride: 4, format: WL_SHM_FORMAT_XRGB8888)

    }
}

func listenerCallback(
    _ data: UnsafeMutableRawPointer?, _ registry: OpaquePointer?, _ name: UInt32,
    _ interface: UnsafePointer<CChar>?, _ version: UInt32
) {
    print("global(listenerCallback): \(name)")
    let interface = String(utf8String: interface!)!

    data?.withMemoryRebound(to: State.self, capacity: 1) { ptr in
        switch interface {
        case String(utf8String: wl_compositor_interface.name)!:
            withUnsafePointer(to: wl_compositor_interface) { interface in
                ptr.pointee.compositor = OpaquePointer(
                    wl_registry_bind(registry, name, interface, 4))
            }

        case String(utf8String: wl_shm_interface.name)!:
            withUnsafePointer(to: wl_shm_interface) { interface in
                ptr.pointee.sharedMemoryBuffer = OpaquePointer(
                    wl_registry_bind(registry, name, interface, 1))
            }

        default:
            return
        // print("interface: \(name) \(interface)")
        }
    }

}
