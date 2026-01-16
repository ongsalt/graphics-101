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
    var xdgWmBase: OpaquePointer!
}

nonisolated(unsafe) var listener = wl_registry_listener(
    global: listenerCallback,
    global_remove: { _, _, _ in
        print("removed")
    }
)

public struct Display {
    var state: State

    public init() throws(InitWaylandError) {
        self.state = State()

        // return
        let waylandDisplay = ProcessInfo.processInfo.environment["WAYLAND_DISPLAY"] ?? "wayland-0"

        guard let display = wl_display_connect(waylandDisplay) else {
            throw .cannotConnect
        }

        let registry = wl_display_get_registry(display)!

        wl_registry_add_listener(registry, &listener, &state)
        wl_display_roundtrip(display)

        // print(state.pointee)

        let w: Int32 = 640
        let h: Int32 = 480
        let size = w * h * 4 * 2

        // let surface = pls_create_surface(state.compositor!)
        let surface = wl_compositor_create_surface(state.compositor!)
        // // sleep(1)

        let shm = SharedMemoryBuffer(shm: self.state.sharedMemoryBuffer, size: UInt(size))
        let pool = shm.createPool()
        let buffer = pool.createBuffer(
            offset: 0, width: w, height: h, stride: 4, format: WL_SHM_FORMAT_XRGB8888)

    }
}

func listenerCallback(
    _ data: UnsafeMutableRawPointer?, _ registry: OpaquePointer?, _ name: UInt32,
    _ interface: UnsafePointer<CChar>?, _ version: UInt32
) {
    // print("global(listenerCallback): \(name)")
    let interface = String(utf8String: interface!)!

    data?.withMemoryRebound(to: State.self, capacity: 1) { ptr in
        switch interface {
        case String(utf8String: WaylandInterfaces.compositor.pointee.name)!:
            ptr.pointee.compositor = OpaquePointer(
                wl_registry_bind(registry, name, WaylandInterfaces.compositor, 4))

        case String(utf8String: WaylandInterfaces.shm.pointee.name)!:
            ptr.pointee.sharedMemoryBuffer = OpaquePointer(
                wl_registry_bind(registry, name, WaylandInterfaces.shm, 1))

        case String(utf8String: WaylandInterfaces.xdgWmBase.pointee.name)!:
            ptr.pointee.xdgWmBase = OpaquePointer(
                wl_registry_bind(registry, name, WaylandInterfaces.xdgWmBase, 1))

        default:
            // print("interface: \(name) \(interface)")
            return
        }
    }

}
