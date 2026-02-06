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
        vertex: [4 of SIMD2<Float>], borderRadius: Float, rotation: Float, gammaA: Float,
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
    var uniqueIndexCount: UInt32 = 0

    for cmd in commands {
        guard case .roundedRectangle(let rect) = cmd else {
            fatalError("not possible")
        }

        let data = rect.toVertexData(indexOffset: uniqueIndexCount)
        uniqueIndexCount += RoundedRectangleDrawCommand.indexCount
        vertexes.append(contentsOf: data.vertexes)
        indexes.append(contentsOf: data.indexes)
    }

    // print(vertexes)
    grouped.append(.main(vertexes: vertexes, indexes: indexes))

    return grouped
}
