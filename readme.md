```bash
swift run -c release && ffmpeg -i ./ppm/%d.ppm ./out/%04d.png -y
```


## Wayland stuff
```bash
cd Sources/CWayland

wayland-scanner private-code < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-protocol.c
wayland-scanner client-header < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-client-protocol.h

wayland-scanner private-code < /usr/share/wayland-protocols/staging/xdg-toplevel-drag/xdg-toplevel-drag-v1.xml > xdg-toplevel-drag-v1-protocol.c
wayland-scanner client-header < /usr/share/wayland-protocols/staging/xdg-toplevel-drag/xdg-toplevel-drag-v1.xml > xdg-toplevel-drag-v1-client-protocol.h
```
