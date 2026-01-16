#include <wayland-client-protocol.h>

struct wl_registry *lwl_display_get_registry(struct wl_display *wl_display) {
  return wl_display_get_registry(wl_display);
}

int lwl_registry_add_listener(struct wl_registry *wl_registry,
                             const struct wl_registry_listener *listener,
                             void *data) {
  return wl_registry_add_listener(wl_registry, listener, data);
}

struct wl_surface *
lwl_compositor_create_surface(struct wl_compositor *wl_compositor) {
    return wl_compositor_create_surface(wl_compositor);
}