extension Image {
    mutating func blur(radius: Float) {
        // gaussianBlur(radius: radius)
        let r = Int(radius)

        // do this for every row
        for y in 0..<height {
            for x in 0..<width {
                var color = colorAt(x: x, y: y)
                for px in -r...r {
                    color = color + colorAt(x: x + px, y: y)
                }

                pixels[getPixelIndex(x: x, y: y)] = color.multiply(scalar: 1 / (radius * 2))
            }
        }

        // vertical pass
        for x in 0..<width {
            for y in 0..<height {
                var color = colorAt(x: x, y: y)
                for py in -r...r {
                    color = color + colorAt(x: x, y: y + py)
                }

                pixels[getPixelIndex(x: x, y: y)] = color.multiply(scalar: 1 / (radius * 2))
            }
        }

    }

    // Expensive
    mutating func gaussianBlur(radius: Float) {
        // let r = Int(radius)
        // let kernel: [[Int]] = Array(repeating: Array(repeating: 0, count: r * 2 + 1), count: r * 2 + 1)

        // for x in 0..<r {
        //     // weight ????
        // }

        // // Convolution
        // for x in 0..<width {
        //     for y in 0..<height {

        //     }
        // }
    }
}
