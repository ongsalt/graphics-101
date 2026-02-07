```bash
swift run -c release && ffmpeg -i ./ppm/%d.ppm ./out/%04d.png -y
```

# Dependencies not included
- wayland devel stuff
- freetype

## Wayland stuff
```bash
cd Sources/CWayland

wayland-scanner private-code < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-protocol.c
wayland-scanner client-header < /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml > xdg-shell-client-protocol.h

wayland-scanner private-code < /usr/share/wayland-protocols/staging/xdg-toplevel-drag/xdg-toplevel-drag-v1.xml > xdg-toplevel-drag-v1-protocol.c
wayland-scanner client-header < /usr/share/wayland-protocols/staging/xdg-toplevel-drag/xdg-toplevel-drag-v1.xml > xdg-toplevel-drag-v1-client-protocol.h
```

## Shader compiler
use [naga](https://github.com/gfx-rs/wgpu/tree/trunk/naga) to compile wgsl to spirv

ok, it doesnt support push constant, use glslc instead

## TODO
- padding, margin
- clip to parent
- clip
- think about pixel perfect stuff
- distance field of composited(?) shape
- use Pango

## Note
- query required gpu features (and optionally provide fallback)
    - VK_EXT_blend_operation_advanced is not supported on my machine (or any amd card) 
- shaders: so we gonna have shit ton of shader
    - roundedrect
    - roundedrect (superellipse)
    - roundedrect (squircle)


