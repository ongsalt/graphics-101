class BaseBox: UIElement {
    // Maybe do this using propertywrapper
    private var _z: (() -> Float)?

    // private var _bounds: (() -> Rect)?
    private var __offset: (() -> SIMD2<Float>)?
    private var _size: (() -> SIMD2<Float>)?

    private var _scale: (() -> Float)?
    private var _rotation: (() -> Float)?
    private var _opacity: (() -> Float)?
    private var _isHidden: (() -> Bool)?
    private var _mask: (() -> Layer?)?
    private var _clipChildren: (() -> Bool)?
    private var _cornerRadius: (() -> Float)?
    private var _borderWidth: (() -> Float)?
    private var _borderColor: (() -> Color)?
    private var _backgroundColor: (() -> Color)?
    private var _transformations: (() -> AffineMatrix)?

    override func place(area: Rect) {
        self.apply(to: layer)
        super.place(area: area)
    }

}

extension BaseBox {
    // MARK: - Modifiers
    // These now simply store the closure into our local properties.

    @discardableResult
    func z(_ value: @autoclosure @escaping () -> Float) -> Self {
        _z = value
        return self
    }

    @discardableResult
    func offset(_ value: @autoclosure @escaping () -> SIMD2<Float>) -> Self {
        __offset = value
        return self
    }

    @discardableResult
    func size(_ value: @autoclosure @escaping () -> SIMD2<Float>) -> Self {
        _size = value
        return self
    }

    @discardableResult
    func scale(_ value: @autoclosure @escaping () -> Float) -> Self {
        _scale = value
        return self
    }

    @discardableResult
    func rotation(_ value: @autoclosure @escaping () -> Float) -> Self {
        _rotation = value
        return self
    }

    @discardableResult
    func opacity(_ value: @autoclosure @escaping () -> Float) -> Self {
        _opacity = value
        return self
    }

    @discardableResult
    func hidden(_ value: @autoclosure @escaping () -> Bool) -> Self {
        _isHidden = value
        return self
    }

    @discardableResult
    func mask(_ value: @autoclosure @escaping () -> Layer?) -> Self {
        _mask = value
        return self
    }

    @discardableResult
    func clipChildren(_ value: @autoclosure @escaping () -> Bool) -> Self {
        _clipChildren = value
        return self
    }

    @discardableResult
    func cornerRadius(_ value: @autoclosure @escaping () -> Float) -> Self {
        _cornerRadius = value
        return self
    }

    @discardableResult
    func border(
        width: @autoclosure @escaping () -> Float, color: @autoclosure @escaping () -> Color
    ) -> Self {
        _borderWidth = width
        _borderColor = color
        return self
    }

    @discardableResult
    func background(_ value: @autoclosure @escaping () -> Color) -> Self {
        _backgroundColor = value
        return self
    }

    @discardableResult
    func transform(_ value: @autoclosure @escaping () -> AffineMatrix) -> Self {
        _transformations = value
        return self
    }

    // MARK: - Hydration
    // Call this when the Layer is finally guaranteed to exist
    // this wont work ????
    func apply(to target: Layer) {
        // Use Effect {} here if your system requires it for binding
        if let v = _z {
            Effect { target.z = v() }
        }

        if let v = _size {
            // must request relayout
            Effect {
                let size = v()
                self._width = size.x
                self._height = size.y
                self.requestRelayout()
            }
        }

        if let v = __offset {
            Effect {
                self._offset = v()
                self.requestReplace()
            }
        }

        // Should this affect layout
        if let v = _scale {
            Effect { target.scale = v() }
        }

        if let v = _rotation {
            Effect { target.rotation = v() }
        }

        if let v = _opacity {
            Effect { target.opacity = v() }
        }

        if let v = _isHidden {
            Effect { target.isHidden = v() }
        }

        if let v = _mask {
            Effect { target.mask = v() }
        }

        if let v = _clipChildren {
            Effect { target.clipChildren = v() }
        }

        if let v = _cornerRadius {
            Effect { target.cornerRadius = v() }
        }

        // Handle composite properties (border needs two checks or one grouped check)
        if let w = _borderWidth {
            Effect { target.borderWidth = w() }
        }
        if let c = _borderColor {
            Effect { target.borderColor = c() }
        }

        if let v = _backgroundColor {
            Effect { target.backgroundColor = v() }
        }

        if let v = _transformations {
            Effect { target.transformations = v() }
        }
    }
}
