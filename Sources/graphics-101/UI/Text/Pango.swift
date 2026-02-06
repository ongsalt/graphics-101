#include <pango/pangoft2.h>

void render_text_to_buffer(const char* text, int width, int height) {
    // 1. Setup Pango-FT2 (Not Cairo!)
    PangoFontMap* fontmap = pango_ft2_font_map_new();
    PangoContext* context = pango_font_map_create_context(fontmap);
    PangoLayout* layout = pango_layout_new(context);

    // 2. Configure Text
    pango_layout_set_text(layout, text, -1); // "สวัสดี..."
    PangoFontDescription* desc = pango_font_description_from_string("Noto Sans Thai 20");
    pango_layout_set_font_description(layout, desc);
    
    // 3. Render to a basic grayscale bitmap (FT_Bitmap)
    // You create a raw FT_Bitmap container for your pixel data
    FT_Bitmap bitmap;
    bitmap.width = width;
    bitmap.rows = height;
    bitmap.pitch = width; // stride
    bitmap.buffer = (unsigned char*)calloc(1, width * height); // Your CPU buffer
    bitmap.pixel_mode = FT_PIXEL_MODE_GRAY;

    // 4. This function rasterizes the layout directly into your buffer
    pango_ft2_render_layout(&bitmap, layout, 0, 0);

    // NOW: 'bitmap.buffer' has your pixels.
    // Upload this to a VkImage (R8_UNORM).
    
    // Cleanup
    free(bitmap.buffer);
    g_object_unref(layout);
    g_object_unref(context);
    g_object_unref(fontmap);
}