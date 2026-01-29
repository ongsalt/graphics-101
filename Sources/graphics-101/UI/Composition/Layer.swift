class Layer {
    unowned let parent: Layer? = nil
    var children: [Layer] = []

    private unowned var compositor: Compositor? = nil {
        didSet {
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

    func getLayerDrawCommands() -> [DrawCommand] {
        var commands: [DrawCommand] = []

        let bg = RoundedRectangleDrawCommand(
            color: duplicated(self.backgroundColor),
            center: self.absoluteFrame.center,
            size: self.absoluteFrame.size,
            borderRadius: self.cornerRadius,
            rotation: self.rotation
        )
        commands.append(DrawCommand.roundedRectangleShadow(bg))

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
