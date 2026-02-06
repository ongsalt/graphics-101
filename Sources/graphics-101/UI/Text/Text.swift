import Foundation
import FreeType

final class Text: UIElement {
    var text: String

    // TODO: AttributedString
    init(_ text: @autoclosure @escaping () -> String) {
        self.text = text()
        super.init()
        Effect {
            self.text = text()
        }
    }

    override func measure(constraints: Constraints) -> SIMD2<Float> {
        var w: Float = 0
        var h: Float = 0

        // TODO: measure text

        return constraints.clamp([w, h])
    }

    override func place(area: Rect) {
        super.place(area: area)
        // var area = area
        // TODO: draw the text
    }
}

extension Text: @MainActor ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public convenience init(stringLiteral: StringLiteralType) {
        self.init(stringLiteral)
    }
}
