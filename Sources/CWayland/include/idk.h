#ifndef I_DONT_WANNA_WRITE_A_CODE_GENERATOR_2_H
#define I_DONT_WANNA_WRITE_A_CODE_GENERATOR_2_H

#include <wayland-client-core.h>

const struct wl_interface *get_wl_surface_interface();
const struct wl_interface *get_wl_shm_interface();
const struct wl_interface *get_wl_compositor_interface();
void *pls_create_surface(struct wl_compositor *wl_compositor);
void whatTheFuck();


#endif