import CWayland
import Glibc

// we shuold actually do codegen
public class XDGTopLevel {
    let topLevel: OpaquePointer

    public init(surface: XDGSurface, title: String = "") {
        self.title = title
        self.topLevel = xdg_surface_get_toplevel(surface.surface)
    }

    public var title: String {
        didSet {
            xdg_toplevel_set_title(topLevel, title)
        }
    }
}
