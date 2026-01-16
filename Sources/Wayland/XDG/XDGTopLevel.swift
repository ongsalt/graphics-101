import CWayland
import Glibc

// we shuold actually do codegen
struct XDGTopLevel {
    let topLevel: OpaquePointer

    init(surface: XDGSurface, title: String = "") {
        self.title = title
        self.topLevel = xdg_surface_get_toplevel(surface.surface)
    }

    var title: String {
        didSet {
            xdg_toplevel_set_title(topLevel, title)
        }
    }
}
