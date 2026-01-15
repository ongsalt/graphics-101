struct Point<T: Numeric> {
    let x: T
    let y: T

    init(_ x: T, _ y: T) {
        self.x = x
        self.y = y
    }
}
