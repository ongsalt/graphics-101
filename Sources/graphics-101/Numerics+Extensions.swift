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
