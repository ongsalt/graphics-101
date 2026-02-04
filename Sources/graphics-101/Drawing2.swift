
        // func addRect(rect: Rect) {
        //     // print(rect)
        //     let l = Layer(rect: rect)
        //     l.backgroundColor = Color.red.multiply(opacity: 0.2)
        //     l.cornerRadius = 36
        //     compositor.rootLayer.addChild(l)

        //     compositor.requestAnimationFrame { progress in
        //         let t = progress / Duration.milliseconds(300)
        //         if t > 1 {
        //             l.scale = 1
        //             l.opacity = 1
        //             return .done
        //         }

        //         // apply p
        //         let p = 1 - Float.pow(1 - Float(t), 4)

        //         l.scale = 1 - 0.2 + p * 0.2
        //         l.opacity = p

        //         return .ongoing
        //     }
        // }

        // Task {
        //     while !Task.isCancelled {
        //         try await Task.sleep(for: .seconds(0.5))
        //         addRect(
        //             rect: Rect(
        //                 center: [.random(in: 0...800), .random(in: 0...600)],
        //                 size: .random(in: 50...200)
        //             )
        //         )
        //     }
        // }
