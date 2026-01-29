#version 450

#extension GL_EXT_buffer_reference : require
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : require


layout(location = 0) in vec4 inColor;
layout(location = 1) in vec4 inSizing; // (cx,cy,w,h)
layout(location = 2) in vec2 borderRadiusAndRotation;
layout(location = 3) in vec2 inScreenSize;

// layout(location = 9) in vec4 c1;
// layout(location = 10) in vec4 c2;
// layout(location = 11) in vec4 c3;
// layout(location = 12) in vec4 c4;


layout(location = 0) out vec4 outFragColor;

void main() {
    vec4 transformed = mat4(c1, c2, c3, v4) * gl_FragCoord
    vec2 p = transformed - inSizing.xy;

    vec2 box = inSizing.zw / 2;
    vec2 q = abs(p) - box + borderRadiusAndRotation.x;

    float inD = min(max(q.x, q.y), 0.0);
    // TODO: pass degreee in
    // float outD = length(max(q,0.0)) - borderRadiusAndRotation.x;
    float outD = pow(dot(pow(max(q, 0.0), vec2(4)), vec2(1.0)), 0.25) - borderRadiusAndRotation.x;

    float d = inD + outD;
    // outFragColor = vec4(d / inSizing.w, 0.0, 0.0, 1.0);

    if (d <= 0) {
        outFragColor = inColor;
    } else {
        outFragColor = vec4(0.0);
    }
}