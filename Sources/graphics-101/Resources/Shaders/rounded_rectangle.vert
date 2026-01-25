#version 450

#extension GL_EXT_buffer_reference : require
#extension GL_EXT_shader_explicit_arithmetic_types_int64 : require

layout(buffer_reference, std430) buffer UniformBufferObject {
    float w;
    float h;
};

layout(push_constant) uniform PushConstants {
    UniformBufferObject ubo; // This is strictly an 8-byte pointer
} pc;


layout(location = 0) in vec4 inColor;
layout(location = 1) in vec4 inSizing; // (cx,cy,w,h)
layout(location = 2) in vec2 borderRadiusAndRotation;
layout(location = 4) in vec2 inVertexPosition;

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outSizing; // (cx,cy,w,h)
layout(location = 2) out vec2 outBorderRadiusAndRotation;

layout(location = 3) out vec2 outScreenSize;


void main() {
    outSizing = inSizing;
    outBorderRadiusAndRotation = borderRadiusAndRotation;
    outScreenSize = vec2(pc.ubo.w, pc.ubo.h);
    
    vec2 scaled_pos = (inVertexPosition / vec2(pc.ubo.w, pc.ubo.h)) * 2.0 - 1.0;

    gl_Position = vec4(scaled_pos, 0.0, 1.0);
    outColor = inColor;
}