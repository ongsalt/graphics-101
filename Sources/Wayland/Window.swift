import Glibc

open class Window {
    // override for window event
    public let display: Display
    public let surface: Surface
    public let xdgSurface: XDGSurface
    public let xdgTopLevel: XDGTopLevel

    public let width: Int32
    public let height: Int32

    // TODO: fix buffer size
    // TODO: move wayland display init out of this
    var shm: SharedMemoryBuffer!
    var pool: SHMPool!
    var buffer: Buffer!

    public var poolData: UnsafeMutableRawPointer {
        pool.poolData
    }

    public init(display: Display, width: Int32 = 640, height: Int32 = 480) {
        self.display = display
        self.width = width
        self.height = height

        let registry = display.registry

        surface = Surface(compositor: registry.compositor)

        let this = Box<Window?>(nil)

        xdgSurface = XDGSurface(
            xdgWmBase: registry.xdgWmBase,
            surface: surface,
            configure: { [this] in
                let this = this.value!
                // this api is shit, TODO: fix it

                this.initBuffer()

                // rendering
            }
        )

        xdgTopLevel = XDGTopLevel(surface: xdgSurface)
        xdgTopLevel.title = "Asd"

        this.value = self

        surface.commit()
        display.dispatch()
    }

    private func initBuffer() {
        if shm != nil { return }

        shm = SharedMemoryBuffer(
            shm: display.registry.sharedMemoryBuffer, size: UInt(width * height * 4 * 4))
        pool = shm.createPool()
        buffer = pool.createBuffer(
            offset: 0, width: width, height: height, stride: 4 * width)

        pool.poolData.initializeMemory(
            as: UInt32.self, repeating: 0xf298_6bff,
            count: Int(width * height * 4 / 2))

        surface.attach(buffer: buffer)
        surface.damage()
        surface.commit()
    }

    public func show() {
        requestRedraw()
    }

    public func requestRedraw(flush: Bool = true) {
        // surface.attach(buffer: buffer)
        surface.damage()
        surface.commit()
        if flush {
            display.flush()
        }
    }

}
