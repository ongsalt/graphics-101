extension Numeric {
    func squared() -> Self {
        return self * self
    }
}

extension Comparable {
    func clamp(_ from: Self, _ to: Self) -> Self {
        max(from, min(self, to))
    }
}

extension SIMD2 where Scalar: FloatingPoint {
    var lenght: Scalar {
        (x.squared() + y.squared()).squareRoot()
    }
}

extension SIMD2 where Scalar: SignedNumeric, Scalar: Comparable {
    func abs() -> Self {
        .init(Swift.abs(x), Swift.abs(y))
    }
}

extension SIMD3 where Scalar: FloatingPoint {
    var lenght: Scalar {
        (x.squared() + y.squared() + z.squared()).squareRoot()
    }
}

// https://en.wikipedia.org/wiki/Error_function#Bounds_and_numerical_approximations

extension Double {
    static let e = exp(1.0)

    static func erf(_ x: Double) -> Double {
        let x = x.clamp(0, 1)

        let a1 = 0.278393
        let a2 = 0.230389
        let a3 = 0.000972
        let a4 = 0.078108

        return 1 - 1
            / Double.pow(
                1 + a1 * x + a2 * Double.pow(x, 2) + a3 * Double.pow(x, 3) + a4 * Double.pow(x, 4),
                4
            )
    }

    func erf() -> Double {
        Double.erf(self)
    }
}
