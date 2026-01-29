enum Invalidation {
    case transformations
    case colors
    case backdropFilters
}

struct DrawInfo {
    let damagedArea: [Rect]
    let commands: GroupedDrawCommand
}