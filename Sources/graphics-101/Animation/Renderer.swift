import Foundation

struct Renderer {
    let frameCount: UInt
    let renderFn: (_ frame: UInt) -> Image

    func render() async throws {
        let progress = Progress(totalUnitCount: Int64(frameCount))

        await withTaskGroup(of: Void.self) { group in
            print("[g101] Rendering...")
            for i in (1...self.frameCount) {
                let image = renderFn(i)

                try! image.save(to: URL(filePath: "./ppm/\(i).ppm"))

                // wtf, concurrency???
                progress.completedUnitCount += 1
            }
        }
    }
}
