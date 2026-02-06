import CFreeType

public struct FreeType {
    nonisolated(unsafe) static var library: FT_Library? = nil

    public static func initialize() {
        FT_Init_FreeType(&library)
    }

    public static func newFace(path: String, faceIndex: Int) -> FT_Face {
        var face: FT_Face? = nil
        FT_New_Face(library, path, faceIndex, &face)

        return face!
    }

}

extension FT_Face {
    public var glyphBitmap: FT_Bitmap {
        self.pointee.glyph.pointee.bitmap
    }

    public func setCharSize(size: Int, dpi: UInt32) {
        FT_Set_Char_Size(self, 0, size * 64, dpi, dpi)
    }

    public func getCharIndex(charcode: UInt) -> UInt32 {
        FT_Get_Char_Index(self, charcode)
    }

    public func loadGlyph(glyphIndex: UInt32, flags: Int32 = FT_LOAD_DEFAULT) {
        FT_Load_Glyph(self, glyphIndex, flags)
    }

    public func renderGlyph(renderMode: FT_Render_Mode = FT_RENDER_MODE_NORMAL) {
        FT_Render_Glyph(self.pointee.glyph, renderMode)
    }

    // TODO: FT_Set_Transform

}
