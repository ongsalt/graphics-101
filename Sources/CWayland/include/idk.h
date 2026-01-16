#ifndef I_DONT_WANNA_WRITE_A_CODE_GENERATOR_2_H
#define I_DONT_WANNA_WRITE_A_CODE_GENERATOR_2_H

#include "xdg-shell-client-protocol.h"
#include <wayland-client-core.h>
#include <wayland-client-protocol.h>

// we can just make a struct
struct _WaylandInterfaces {
  struct wl_interface *surface;
  struct wl_interface *shm;
  struct wl_interface *compositor;
  struct wl_interface *xdgWmBase;
};

const struct _WaylandInterfaces WaylandInterfaces = {
    .surface = &wl_surface_interface,
    .shm = &wl_shm_interface,
    .compositor = &wl_compositor_interface,
    .xdgWmBase = &xdg_wm_base_interface};

void *pls_create_surface(struct wl_compositor *wl_compositor);
void whatTheFuck();

#endif