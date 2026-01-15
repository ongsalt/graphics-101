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

