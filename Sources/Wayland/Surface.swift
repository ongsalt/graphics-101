import CWayland

struct Surface {
    let surface: OpaquePointer

    init() {
        surface = OpaquePointer(UnsafeRawPointer(bitPattern: 1)!)
    }

    func attach(buffer: Buffer, x: Int32, y: Int32) {
        wl_surface_attach(surface, buffer.buffer, x, y);
    }

    func damage() {
        damage(x: 0, y: 0, width: Int32.max, height: Int32.max)
    }

    func damage(x: Int32, y: Int32, width: Int32, height: Int32) {
        wl_surface_damage(surface, x, y, width, height);
    }

    func commit(buffer: Buffer, x: Int32, y: Int32) {
        wl_surface_commit(surface)
    }
}
