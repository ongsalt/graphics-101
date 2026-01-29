struct PointWithColor {
    let x: Float
    let y: Float
    let color: Color
}

// enum PipelineType {
//     case main
// }

enum DrawCommand {
    case triangle(vertex: [3 of PointWithColor])
    case roundedRectangle(RoundedRectangleDrawCommand)
    // clipping?a

    case blur(
        vertex: [4 of Point<Float>], borderRadius: Float, rotation: Float, gammaA: Float,
        gammaB: Float)
}

// it shuold be enum{ pipelineType([itsCommand]) }
enum GroupedDrawCommand {
    case main(vertexes: [RoundedRectangleVertexData], indexes: [UInt32])
}

// sort render command
// there is a flutter talk, about render command recording, ordering?

// TODO: actually sort/group it
func groupDrawCommand(commands: [DrawCommand]) -> [GroupedDrawCommand] {
    var grouped: [GroupedDrawCommand] = []

    var vertexes: [RoundedRectangleVertexData] = []
    var indexes: [UInt32] = []
    for (i, cmd) in commands.enumerated() {
        guard case .roundedRectangle(let rect) = cmd else {
            fatalError("not possible")
        } 
        let data = rect.toVertexData(indexOffset: UInt32(i))
        vertexes.append(contentsOf: data.vertexes)
        indexes.append(contentsOf: data.indexes)
    }

    grouped.append(.main(vertexes: vertexes, indexes: indexes))
    return grouped
}