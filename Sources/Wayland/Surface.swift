import CWayland

public class Surface {
    let surface: OpaquePointer
    private var runLoopObserver: RunLoopObserver? = nil

    public init(compositor: OpaquePointer, autoCommit: Bool = true) {
        surface = wl_compositor_create_surface(compositor)

        // auto commit ?
        if autoCommit {
            runLoopObserver = RunLoopObserver(on: [.beforeWaiting]) { [unowned self] actvity in
                print("[before idle] commit")
                wl_surface_commit(self.surface)
            }
        }

        // wl_surface_

    }

    public func attach(buffer: Buffer, x: Int32 = 0, y: Int32 = 0) {
        wl_surface_attach(surface, buffer.buffer, x, y)
    }

    public func damage() {
        damage(x: 0, y: 0, width: Int32.max, height: Int32.max)
    }

    public func damage(x: Int32, y: Int32, width: Int32, height: Int32) {
        wl_surface_damage(surface, x, y, width, height)
    }

    public func commit() {
        wl_surface_commit(surface)
    }
}
