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
                let this = Unmanaged<XDGTopLevel>.fromOpaque(data!).takeUnretainedValue()

            },
            close: { (data, topLevel) in
                let this = Unmanaged<XDGTopLevel>.fromOpaque(data!).takeUnretainedValue()

            },
            configure_bounds: { (data, topLevel, w: Int32, h: Int32) in
                let this = Unmanaged<XDGTopLevel>.fromOpaque(data!).takeUnretainedValue()

            },
            wm_capabilities: { (data, topLevel, wtf: UnsafeMutablePointer<wl_array>?) -> Void in
                let this = Unmanaged<XDGTopLevel>.fromOpaque(data!).takeUnretainedValue()

            }
        )

        // print(observer)
        let this = Unmanaged.passUnretained(self).toOpaque()
        xdg_toplevel_add_listener(topLevel, &listener, this)
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
