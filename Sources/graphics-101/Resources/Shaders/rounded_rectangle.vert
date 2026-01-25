#version 450

layout(push_constant) uniform UniformBufferObject {
    float w;
    float h;
} ubo;


layout(location = 0) in vec4 inColor;
layout(location = 1) in vec4 inSizing;
layout(location = 4) in vec2 inVertexPosition;

layout(location = 0) out vec4 outColor;

void main() {
    vec2 scaled_pos = (inVertexPosition / vec2(ubo.w, ubo.h)) * 2.0 - 1.0;
    
    gl_Position = vec4(scaled_pos, 0.0, 1.0);
    outColor = inColor;
}