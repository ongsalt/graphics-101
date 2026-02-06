// well, just drareaaw command recorder
class DrawController {
    func pushTransformation() {}
    func popTransformation() {}
    func add(_ command: DrawCommand) {}
    func addDamageRegion() {}
}

struct Size {}

protocol Widget {
    func measure(constrants: Constraints) -> Size

    /// the widget wont know its absolute position
    /// the framework should call this for every node/child
    func draw(controller: DrawController, size: Size)

    var children: [Widget] {
        get
    }
}

/// the framework need to know each widget draw command and area on screen
/// to hit test and redraw when in damage area
/// Planning redraw:
/// - some widget emit damage rect because of state change or smth
///     - it need to invalidate it draw command too
/// - get draw command: use recorded first, rerecord if need (for now just dint fucking record it)
/// - group/process it (our command not vertex data)
/// - translate it to vulkan call
/// 
/// WE KNOW EXACTLY WHAT WILL CHANGE tho
/// 
