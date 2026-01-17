import Glibc

open class Window {
    // override for window event
    public let display: Display
    public let surface: Surface
    public let xdgSurface: XDGSurface
    public let xdgTopLevel: XDGTopLevel

    public let width: Int32
    public let heigh: Int32

    // TODO: fix buffer size
    lazy var shm = SharedMemoryBuffer(
        shm: display.registry.sharedMemoryBuffer, size: UInt(width * heigh * 4 * 4))
    lazy var pool = shm.createPool()
    lazy var buffer = pool.createBuffer(offset: 0, width: width, height: heigh, stride: 4 * width)

    public init() throws(InitWaylandError) {
        display = try Display()
        let registry = display.registry

        width = 640
        heigh = 480
        // let size = width * heigh * 4 * 4

        surface = Surface(compositor: registry.compositor)
        // let this = TrustMeBro<Window>()
        let this = Box<Window?>(nil)

        xdgSurface = XDGSurface(
            xdgWmBase: registry.xdgWmBase,
            surface: surface,
            configure: { [this] in
                let this = this.value!
                // this api is shit, TODO: fix it
                
                memset(this.pool.poolData, 0xf2986b, Int(this.width * this.heigh * 4 / 2))
                // rendering

                this.surface.attach(buffer: this.buffer)
                this.surface.damage()
                this.surface.commit()
            }
        )

        xdgTopLevel = XDGTopLevel(surface: xdgSurface)
        xdgTopLevel.title = "Asd"

        this.value = self

        surface.commit()
        display.roundtrip()
        display.dispatch()

        display.monitorEvents()
    }
}
