import CPango

public class PangoFontDescription {
    public let desc: OpaquePointer

    public init(_ fontDescription: String) {
        desc = pango_font_description_from_string(fontDescription)
    }

    public init(family: String, size: Int) {
        desc = pango_font_description_from_string("\(family) \(size)")
    }

    deinit {
        pango_font_description_free(desc)
    }
}
