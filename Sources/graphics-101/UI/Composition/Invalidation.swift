enum Invalidation {
    case transformations
    case paint
    case backdropFilters
    case existence
}

struct DrawInfo {
    let damagedArea: [Rect]
    let commands: [GroupedDrawCommand]
}

// extension Array where Element == Rect {
//     func 
// }