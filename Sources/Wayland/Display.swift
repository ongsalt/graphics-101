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

public struct Registry {
    public internal(set) var compositor: OpaquePointer!
    public internal(set) var sharedMemoryBuffer: OpaquePointer!
    public internal(set) var xdgWmBase: OpaquePointer!
}

nonisolated(unsafe) var listener = wl_registry_listener(
    global: listenerCallback,
    global_remove: { _, _, _ in
        print("removed")
    }
)

public class Display: @unchecked Sendable {
    public private(set) var registry: Registry
    let display: OpaquePointer
    let fd: Int32

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

    public func monitorEvents(
        runloop: RunLoop,
    ) {

    }

    public func monitorEvents(
        on queue: DispatchQueue,
    ) {
        queue.async {
            while !Task.isCancelled {
                let n = self.dispatch()
                print("processed \(n) events")
            }
        }
    }

    // this is ass
    public func monitorEvents(
        on listenQueue: DispatchQueue = .global(qos: .default),
        dispatchOn runQueue: DispatchQueue,
    ) {
        let poller = initPolling()

        listenQueue.async {
            // let a = DispatchSource.makeReadSource(fileDescriptor: 1)
            while !Task.isCancelled {
                while self.prepareRead() != 0 {
                    _ = runQueue.sync { self.dispatchPending() }
                }
                self.flush()

                poller.wait()

                self.readEvent()
                runQueue.async {
                    let n = self.dispatchPending()
                    // print("processed \(n) events")
                }
            }
        }
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

    @discardableResult
    public func initPolling() -> EventPoller {
        EventPoller(displayFd: fd)
    }

    public var handle: FileHandle {
        FileHandle(fileDescriptor: fd)
    }
}

public final class EventPoller: Sendable {
    let fd: Int32

    init(displayFd: Int32) {
        self.fd = epoll_create1(0)

        var ev = epoll_event(
            events: EPOLLIN.rawValue | EPOLLET.rawValue, data: .init(fd: displayFd))
        epoll_ctl(fd, EPOLL_CTL_ADD, displayFd, &ev)
    }

    public func wait() {
        var events: [epoll_event] = []
        epoll_wait(fd, &events, 1, -1)
    }

    public consuming func destroy() {
        close(fd)
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

        default:
            // print("interface: \(name) \(interface)")
            return
        }
    }

}
