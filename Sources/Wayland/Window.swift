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
    lazy var shm: SharedMemoryBuffer = SharedMemoryBuffer(
        shm: display.registry.sharedMemoryBuffer, size: UInt(width * height * 4 * 4))
    public lazy var pool: SHMPool = shm.createPool()
    lazy var buffer: Buffer = pool.createBuffer(
        offset: 0, width: width, height: height, stride: 4 * width)

    public var poolData: UnsafeMutableRawPointer {
        pool.poolData
    }

    public init() throws(InitWaylandError) {
        display = try Display()
        let registry = display.registry

        width = 640
        height = 480
        // let size = width * height * 4 * 4

        surface = Surface(compositor: registry.compositor)
        // let this = TrustMeBro<Window>()
        let this = Box<Window?>(nil)
        var onced = false
        xdgSurface = XDGSurface(
            xdgWmBase: registry.xdgWmBase,
            surface: surface,
            configure: { [this] in
                let this = this.value!
                // this api is shit, TODO: fix it

                print("configure requested")
                if !onced {
                    print("recrreate")
                    this.pool.poolData.initializeMemory(
                        as: UInt32.self, repeating: 0xf298_6bff,
                        count: Int(this.width * this.height * 4 / 2))
                    onced = true

                    this.surface.attach(buffer: this.buffer)
                    this.surface.damage()
                    this.surface.commit()
                }

                // rendering
            }
        )

        xdgTopLevel = XDGTopLevel(surface: xdgSurface)
        xdgTopLevel.title = "Asd"

        this.value = self

        surface.commit()
        display.roundtrip()
        display.dispatch()
    }

    public func show() {
        requestRedraw()
        display.monitorEvents()
    }

    public func requestRedraw() {
        surface.attach(buffer: buffer)
        surface.damage()
        surface.commit()
    }

}
