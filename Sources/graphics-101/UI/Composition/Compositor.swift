import Wayland

class Compositor {
    let rootLayer: Layer
    var damagedLayers: [Layer: [Invalidation]] = [:]

    init(size: SIMD2<Float>) {
        rootLayer = Layer(rect: Rect(top: 0, left: 0, width: size.x, height: size.y))
    }

    func invalidateLayer(layer: Layer, invalidation: Invalidation) {
        // tell someone we need rerender, kinda requestAnimationFrame

        self.damagedLayers[layer, default: []].append(invalidation)
    }

    func flushDrawCommand() -> DrawInfo {
        defer { damagedLayers = [:] }
        
        // this is just redraw everything
        var commands: [DrawCommand] = []
        
        func traverse(layer: Layer, commands: inout [DrawCommand]) {
            commands.append(contentsOf: layer.getLayerDrawCommands())

            for c in layer.children {
                traverse(layer: c, commands: &commands)
            }
        }

        traverse(layer: rootLayer, commands: &commands)


        return DrawInfo(damagedArea: [rootLayer.bounds], commands: groupDrawCommand(commands: commands)) 
        // var commands: [DrawCommand] = []
        // // damagedLayers

        // let info = DrawInfo(damagedArea: [], commands: groupDrawCommand(commands: commands))

        // return info
    }

}

/// Alternative: CALayer style
/// - we gonna have a layer tree which will or will not contain backing texture
/// - transformation
/// - or just make 1 layer a fucking rounded rect
/// - clipping
///     - clip sublayer to parent (easy: no texture need, just more vertex data)
///     - clip to other layer (alpha map??)
/// - sublayer...
/// - backdrop filter
/// - Compositing/color blend mode
/// - damage reporting
/// - this do make some behavior easier:
///     - hitbox can easily be independent of layout animation
///     - alternative: lookahead scope?
///     - how does flutter do this
/// - Compositor then
///     - batch change (Layer, [Change])
///     - for now, just use the most retard way: redraw everything
///     - at least 3 layer
///     - below, above, animating
///
///
