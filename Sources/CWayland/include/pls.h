#ifndef I_DONT_WANNA_WRITE_A_CODE_GENERATOR_H
#define I_DONT_WANNA_WRITE_A_CODE_GENERATOR_H

#include "wayland-client-protocol.h"

struct wl_registry *lwl_display_get_registry(struct wl_display *wl_display);

int lwl_registry_add_listener(struct wl_registry *wl_registry,
                              const struct wl_registry_listener *listener,
                              void *data);

struct wl_surface *
lwl_compositor_create_surface(struct wl_compositor *wl_compositor);

#endif