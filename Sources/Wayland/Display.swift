import CWayland
import Foundation
import Glibc

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

public struct Registry {
    public internal(set) var compositor: OpaquePointer!
    public internal(set) var sharedMemoryBuffer: OpaquePointer!
    public internal(set) var xdgWmBase: OpaquePointer!
    public internal(set) var xdgTopLevelDrag: XDGTopLevelDrag!
}

nonisolated(unsafe) var listener = wl_registry_listener(
    global: listenerCallback,
    global_remove: { _, _, _ in
        print("removed")
    }
)

public class Display: @unchecked Sendable {
    public private(set) var registry: Registry
    public let display: OpaquePointer
    let fd: Int32

    private var source: (any DispatchSourceRead)? = nil
    public var isMonitoring: Bool {
        source != nil
    }

    public init() throws(InitWaylandError) {
        self.registry = Registry()

        // return
        let waylandDisplay = ProcessInfo.processInfo.environment["WAYLAND_DISPLAY"] ?? "wayland-0"

        guard let display = wl_display_connect(waylandDisplay) else {
            throw .cannotConnect
        }

        self.display = display
        self.fd = wl_display_get_fd(display)

        let registry = wl_display_get_registry(display)!

        wl_registry_add_listener(registry, &listener, &self.registry)
        _ = roundtrip()
    }

    // this is ass
    public func monitorEvents(
        queue: DispatchQueue = .main,
    ) {
        guard self.source == nil else { return }

        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        source.setEventHandler { [unowned self] in
            self.prepareRead()
            self.readEvent()
            self.dispatchPending()
            self.flush()
        }

        source.resume()
        self.source = source
    }

    public func stopMonitoring() {
        self.source = nil
    }

    @discardableResult
    public func dispatch() -> Int32 {
        wl_display_dispatch(display)
    }
    @discardableResult
    public func dispatchPending() -> Int32 {
        wl_display_dispatch_pending(display)
    }

    @discardableResult
    public func flush() -> Int32 {
        wl_display_flush(display)
    }

    @discardableResult
    public func prepareRead() -> Int32 {
        wl_display_prepare_read(display)
    }

    @discardableResult
    public func readEvent() -> Int32 {
        wl_display_read_events(display)
    }

    @discardableResult
    public func roundtrip() -> Int32 {
        wl_display_roundtrip(display)
    }

    public var handle: FileHandle {
        FileHandle(fileDescriptor: fd)
    }
}

nonisolated(unsafe) private var pongListener = xdg_wm_base_listener { data, xdgWmBase, serial in
    // wtf, it crash if i uncomment this
    // print("ping")
    xdg_wm_base_pong(xdgWmBase, serial)
}

func listenerCallback(
    _ data: UnsafeMutableRawPointer?, _ registry: OpaquePointer?, _ name: UInt32,
    _ interface: UnsafePointer<CChar>?, _ version: UInt32
) {
    // print("global(listenerCallback): \(name)")
    let interface = String(utf8String: interface!)!

    data?.withMemoryRebound(to: Registry.self, capacity: 1) { ptr in
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

            xdg_wm_base_add_listener(
                ptr.pointee.xdgWmBase,
                &pongListener,
                nil
            )

        case String(utf8String: WaylandInterfaces.xdgToplevelDragV1.pointee.name)!:
            ptr.pointee.xdgTopLevelDrag = XDGTopLevelDrag(
                OpaquePointer(
                    wl_registry_bind(registry, name, WaylandInterfaces.xdgToplevelDragV1, 1))
            )

        default:
            // print("interface: \(name) \(interface)")
            return
        }
    }

}
