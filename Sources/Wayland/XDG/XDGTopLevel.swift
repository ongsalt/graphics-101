import CWayland
import Foundation
import Glibc

// we should actually do codegen

public class XDGTopLevel {
    let topLevel: OpaquePointer
    private var listener: xdg_toplevel_listener

    public init(surface: XDGSurface, title: String = "App", appId: String = UUID().uuidString) {
        self.title = title
        self.appId = appId
        self.topLevel = xdg_surface_get_toplevel(surface.surface)

        listener = xdg_toplevel_listener(
            configure: { (data, topLevel, w: Int32, h: Int32, _: UnsafeMutablePointer<wl_array>?) in

            },
            close: { (data, topLevel) in

            },
            configure_bounds: { (data, topLevel, w: Int32, h: Int32) in

            },
            wm_capabilities: { (data, topLevel, wtf: UnsafeMutablePointer<wl_array>?) -> Void in

            }
        )

        // print(observer)
        xdg_toplevel_add_listener(topLevel, &listener, nil)
    }

    public var title: String {
        didSet {
            xdg_toplevel_set_title(topLevel, title)
        }
    }

    public var appId: String {
        didSet {
            xdg_toplevel_set_app_id(topLevel, appId)
        }
    }

}
