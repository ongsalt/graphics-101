```bash
swift run -c release && ffmpeg -i ./ppm/%d.ppm ./out/%04d.png -y
```


## Wayland stuff
```bash
cd Sources/CWayland

wayland-scanner private-code < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-protocol.c

wayland-scanner client-header < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-client-protocol.h

wayland-scanner client-header < /usr/share/wayland/wayland.xml > wayland-client-protocol.h

# This is ass, im gonna proper codegen later
sed -i 's/static inline//g' wayland-client-protocol.h
```

then pls remove every `static inline`