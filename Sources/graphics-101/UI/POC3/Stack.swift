class ZStack: UIBox {
    override func measure(constraints: Constraints) -> SIMD2<Float> {
        var w: Float = 0
        var h: Float = 0

        let childConstraints = Constraints(minSize: .zero, maxSize: constraints.maxSize)

        for child in children {
            // needX is different for each container type
            let size =
                if child.parentData!.needRemeasure {
                    child.measure(constraints: childConstraints)
                } else {
                    child.parentData!.decidedSize
                }

            if size != child.parentData!.decidedSize {
                child.parentData!.needReplace = true
            }

            w = max(w, size.x)
            h = max(w, size.y)

            child.parentData!.previousConstraints = childConstraints
            child.parentData!.decidedSize = childConstraints.clamp(size)
            // print(child.layer.backgroundColor)
            // print(child.parentData!)
            child.parentData!.needRemeasure = false
        }

        return constraints.clamp([w, h])
    }

    override func place(area: Rect) {
        super.place(area: area)
        // var area = area

        for child in children {
            if !child.parentData!.needReplace {
                continue
            }
            let childArea = Rect(topLeft: area.topLeft, size: child.parentData!.decidedSize)
            child.place(area: childArea)

            child.parentData!.finalRect = area
            child.parentData!.needReplace = false
        }
    }
}
