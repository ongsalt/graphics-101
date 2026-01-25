struct VertexInput {
  @location(0) color: vec4<f32>,
  @location(1) sizing: vec4<f32>
}

struct VertexOutput {
  @builtin(position) position: vec4<f32>,
  @location(0) color: vec4<f32>
}

struct FragmentInput {
  @location(0) color: vec4<f32>
}

@vertex
fn vtx_main(@builtin(vertex_index) vertex_index : u32, input: VertexInput) -> VertexOutput {
  let position = vec4<f32>(input.sizing.x, input.sizing.y, 0, 1);
  return VertexOutput(position, input.color);
}

@fragment
fn frag_main(input: FragmentInput) -> @location(0) vec4<f32> {
  return input.color;
}
