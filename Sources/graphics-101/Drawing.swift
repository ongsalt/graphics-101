import Synchronization
import Foundation
import Wayland

// TODO: reuse image texture
func createImage(width: Int, height: Int, padding: Float = 24, cornerRadius: Float = 36) -> Image {
    var image = Image(width: width, height: height, fill: .transparent)  // Color(rgba: 0x0000ff30)

    let bound = image.rect.padded(-padding)

    let p = Int(padding)
    // TODO: set global clip

    image.drawRoundedRectangleShadow(
        rect: bound, cornerRadius: cornerRadius / 1.8, color: Color(rgba: 0x0000_0045), blur: 24)

    image.fillRoundedRectangle(
        rect: bound,
        cornerRadius: cornerRadius
    ) { x, y, _ in
        Color(
            r: Float(x) / Float(width) / 3 + 0.3,
            g: 0.3,
            b: Float(y) / Float(height) / 3 + 0.3,
            a: 1.0)
    }

    image.fillRoundedRectangleBorder(
        rect: bound.padded(-0.5),
        cornerRadius: cornerRadius,
        borderWidth: 1
    ) { x, y, below in
        // Color.black.lerp(over: below, progress: 0.2)
        Color(rgb: 0x454545).overlay(over: below)
    }

    image.fillRoundedRectangleBorder(
        rect: bound.padded(-1),
        cornerRadius: cornerRadius,
        borderWidth: 1
    ) { x, y, below in
        // Color.black.lerp(over: below, progress: 0.2)
        Color(rgb: 0xdedede).overlay(over: below)
    }

    let center: (Float, Float) = (280 + padding, 280 + padding)
    let radius: Float = 180
    // image.fillSuperellipse(center: center, radius: radius, degree: 4) {
    image.fillRectangle(
        rect: Rect(
            top: center.1 - radius, left: center.0 - radius, width: radius * 2, height: radius * 2)
    ) {
        x, y, below in
        Color(
            r: ((Float(x) - center.0) + radius) / (radius * 2),
            g: (-(Float(y) - center.1) + radius) / (radius * 2),
            b: 0.5,
            a: 1.0)
    }

    let rect = Rect(top: 24 + padding, left: 24 + padding, width: 90 * 1.5, height: 195 * 1.5)
    var blurTexture = image.cropped(at: rect)

    // box blur look like shit
    blurTexture.blur(radius: 25)
    blurTexture.blur(radius: 25)

    // TODO: clip
    // image.blit(from: blurTexture, to: rect)

    // TODO: saturation
    image.fillRoundedRectangle(rect: rect, cornerRadius: 48) { x, y, below in
        // below.overlay(.white)
        // below.multiply(scalar: 2)
        Color(r: 0.7, g: 0.7, b: 0.7, a: 0.7)
            .lerp(
                over:
                    blurTexture
                    .colorAt(x: x - Int(rect.left), y: y - Int(rect.top))
                    // probably gonna do brighness curve shit
                    .multiply(scalar: 1.7)
            )
    }

    return image
}

func runOldImpl() throws {
    let display = try Display()
    display.monitorEvents()
    // auto flush?
    let token = RunLoop.main.addListener(on: [.beforeWaiting]) { _ in
        display.flush()
    }

    let padding: Float = 18
    let width = 640 + 2 * padding
    let height = 480 + 2 * padding

    let shm = SharedMemoryBuffer(
        shm: display.registry.sharedMemoryBuffer)
    let pool = shm.createPool(size: Int32(width * height * 4 * 4))

    let window = Window(display: display, pool: pool, width: Int32(width), height: Int32(height))
    window.show()

    // launchCounter()

    // _ = consume observer

    // window.surface.onFrame(runImmediately: true) {
    //     // print("called")
    //     padding += 1


    Task {
        let start = ContinuousClock.now
        let image = await Task.detached { [padding] in
            createImage(width: Int(width), height: Int(height), padding: padding)
        }.value

        // ideally image.write(to: surface, rect: Rect())
        image.write(to: window.currentBuffer.bufferData)  // for now
        window.requestRedraw()
        display.flush()
        let end = ContinuousClock.now
        print("Done in \(end - start)")
        // bruh
    }


    RunLoop.main.run()
    _ = consume token
}
