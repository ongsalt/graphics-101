class Layer {
    unowned let parent: Layer? = nil
    var children: [Layer] = []

    unowned var compositor: Compositor? = nil {
        didSet {
            compositor?.invalidateLayer(layer: self, invalidation: .existence)
            for c in self.children {
                c.compositor = compositor
            }
        }
    }

    var z: Float = 1
    // This should be readonly
    var frame: Rect = .zero {
        didSet {
            invalidate(.transformations)
        }
    }
    var bounds: Rect = .zero {
        didSet {
            invalidate(.transformations)
        }
    }

    var absoluteFrame: Rect {
        // TODO: affine transform
        frame.offset(parent?.absoluteFrame.topLeft ?? .zero)
    }

    var scale: Float = 1
    var rotation: Float = 0
    var opacity: Float = 1
    var isHidden: Bool = false
    var mask: Layer? = nil
    var clipChildren: Bool = true
    var cornerRadius: Float = 0

    var borderWidth: Float = 0
    var borderColor: Color = .transparent

    var backgroundColor: Color = .transparent

    var transformations: AffineMatrix = .identity
    var totalTransformation: AffineMatrix {
        transformations * mtx
    }

    private var mtx: AffineMatrix {
        var mtx = AffineMatrix.identity
        mtx.scale(x: scale, y: scale, z: scale)
        mtx.rotate(angleRadians: rotation, axis: [0, 0, 1])
        return mtx
    }
    // how to do brush tho

    // var shadow: Shadow
    // lightingggggg

    var filters: [Any] = []
    var backdropFilters: [Any] = []

    // var shouldRasterize: Bool = false

    init() {
    }

    convenience init(rect: Rect) {
        self.init()
        self.frame = rect
        self.bounds = rect.atOrigin
    }

    func addChild(_ layer: Layer) {
        if let compositor {
            layer.compositor = compositor
        }

        self.children.append(layer)
    }

    func invalidate(_ type: Invalidation) {
        compositor?.invalidateLayer(layer: self, invalidation: type)
    }

    func getLayerDrawCommands(transformation: AffineMatrix) -> [DrawCommand] {
        var commands: [DrawCommand] = []

        let bg = RoundedRectangleDrawCommand(
            color: duplicated(self.backgroundColor.multiply(opacity: opacity).premulitplied()),
            center: self.absoluteFrame.center,
            size: self.absoluteFrame.size * scale,
            borderRadius: self.cornerRadius,
            rotation: self.rotation
        )
        commands.append(DrawCommand.roundedRectangle(bg))

        return commands
    }
}

extension Layer: Identifiable {}

extension Layer: Hashable {
    static func == (lhs: Layer, rhs: Layer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
