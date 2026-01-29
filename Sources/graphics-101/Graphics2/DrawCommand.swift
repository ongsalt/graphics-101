struct PointWithColor {
    let x: Float
    let y: Float
    let color: Color
}

enum PipelineType {
    case main
}

enum DrawCommand {
    case triangle(vertex: [3 of PointWithColor])
    case roundedRectangle(vertex: [4 of PointWithColor], borderRadius: Float, rotation: Float)
    // clipping?a

    case blur(
        vertex: [4 of Point<Float>], borderRadius: Float, rotation: Float, gammaA: Float,
        gammaB: Float)

    case roundedRectangleShadow(RoundedRectangleDrawCommand)
}

typealias GroupedDrawCommand = [(PipelineType, [DrawCommand])]

// sort render command
// there is a flutter talk, about render command recording, ordering?

func groupDrawCommand(commands: [DrawCommand]) -> GroupedDrawCommand {
    []
}