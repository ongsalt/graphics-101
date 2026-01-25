@preconcurrency import CVMA
import Foundation
import Wayland

class GraphicsPipeline {
    init(
        device: VkDevice,
        swapChain: SwapChain,
        shader: Shader,
        vertexEntry: String,
        fragmentEntry: String,
        viewportExtent: VkExtent2D,
        imageFormat: VkFormat
        // bind point
        // blending
    ) {

    }

    func bind(commandBuffer: VkCommandBuffer) {
        // vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, self.pipeline)
    }
}
