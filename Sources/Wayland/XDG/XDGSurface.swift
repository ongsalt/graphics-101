import CWayland
import Glibc

// we shuold actually do codegen
class XDGSurface {
    let surface: OpaquePointer
    var listener: xdg_surface_listener
    let configure: () -> Void

    init(
        xdgWmBase: OpaquePointer, surface waylandSurface: Surface,
        configure: @escaping () -> Void = {}
    ) {
        self.configure = configure
        self.surface = xdg_wm_base_get_xdg_surface(xdgWmBase, waylandSurface.surface)

        listener = xdg_surface_listener { data, surface, serial -> Void in
            Retained<XDGSurface>.run(fromPointer: data!) { this in
                this.configure()

                xdg_surface_ack_configure(this.surface, serial)
            }
        }

        let this = Retained(self)
        xdg_surface_add_listener(self.surface, &listener, this.pointer())
    }
}
