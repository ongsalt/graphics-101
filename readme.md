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

## Shader compiler
use [naga](https://github.com/gfx-rs/wgpu/tree/trunk/naga) to compile wgsl to spirv

ok, it doesnt support push constant, use glslc instead

## TODO
- clip
- stop using Observation framework becuase no untrack
- concurrency safe signal
- think about pixel perfect stuff
- distance field of composited(?) shape

## Note
- query required gpu features (and optionally provide fallback)
    - VK_EXT_blend_operation_advanced is not supported on my machine 
- shaders: so we gonna have shit ton of shader
    - roundedrect
    - roundedrect (superellipse)
    - roundedrect (squircle)

### draw command recording
- each node will emit
1. our draw command
2. damaged region 
3. some other info (used in flutter)

- combine damaged node draw command and other node in that region 
- convert our draw command to vulkan's
    - need to merge/reorder some command to minimize work
- set scissor to damaged region
- send it to gpu



