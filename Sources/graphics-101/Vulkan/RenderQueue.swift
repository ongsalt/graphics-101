@preconcurrency import CVMA
import Foundation
import Wayland

class RenderQueue {
    let state: VulkanState

    init(state: VulkanState) {
        self.state = state
    }

    func performBs() {
        let shader = try! Shader(filename: "triangle.spv", device: state.device)
        let pipeline = GraphicsPipeline(
            device: state.device,
            swapChain: state.swapChain,
            vertexShader: shader,
            fragmentShader: shader,
            vertexEntry: "vtx_main",
            fragmentEntry: "frag_main",
        )

        perform { commandBuffer, swapChain in
            var viewport = VkViewport(
                x: 0,
                y: 0,
                width: Float(swapChain.extent.width),
                height: Float(swapChain.extent.height),
                minDepth: 0.0,
                maxDepth: 1.0
            )
            vkCmdSetViewport(commandBuffer, 0, 1, &viewport)

            var scissor = VkRect2D(
                offset: VkOffset2D(x: 0, y: 0),
                extent: swapChain.extent
            )

            vkCmdSetScissor(commandBuffer, 0, 1, &scissor)
            vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline.pipeline)

            vkCmdDraw(commandBuffer, 3, 1, 0, 0)
        }
    }

    func perform(blocking: Bool = false, _ block: (VkCommandBuffer, SwapChain) -> Void) -> Bool {
        // Logger.info(.renderLoop, "perform 1 pass")
        let swapChain = state.swapChain
        let frameIndex = swapChain.frameIndex

        // TODO: epoll/DispatchSource.makeReadSource
        if blocking {
            swapChain.waitForFence(frameIndex: frameIndex)
        } else {
            if !swapChain.isFenceCompleted(frameIndex: frameIndex) {
                return false
            }
            swapChain.resetFence(frameIndex: frameIndex)
        }

        let (image, imageView, imageIndex) = swapChain.acquireNextImage()

        // update shader data: https://www.howtovulkan.com/#shader-data-buffers
        // well, we have no shader data yet

        // record command buffer
        let commandBuffer = state.commandBuffers[frameIndex]
        vkResetCommandBuffer(commandBuffer, 0).unwrap()
        var commandBufferCI = with(VkCommandBufferBeginInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
            $0.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT.rawValue
        }
        vkBeginCommandBuffer(commandBuffer, &commandBufferCI).unwrap()

        // Transition swapchain image to attachment optimal layout
        let imageBarrier = Box(VkImageMemoryBarrier2()) {
            $0.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2
            $0.srcStageMask = VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT
            $0.srcAccessMask = 0
            $0.dstStageMask = VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT
            $0.dstAccessMask =
                VK_ACCESS_2_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_2_COLOR_ATTACHMENT_WRITE_BIT
            $0.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED
            $0.newLayout = VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL
            $0.image = image
            $0.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            $0.subresourceRange.levelCount = 1
            $0.subresourceRange.layerCount = 1
        }

        let dependencyInfo = Box(VkDependencyInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_DEPENDENCY_INFO
            $0.imageMemoryBarrierCount = 1
            $0.pImageMemoryBarriers = imageBarrier.readonly
        }

        vkCmdPipelineBarrier2(commandBuffer, dependencyInfo.ptr)

        // Setup rendering attachment
        // print(swapChain.surfaceFormat)
        let colorAttachmentInfo = Box(VkRenderingAttachmentInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO
            $0.imageView = imageView
            $0.imageLayout = VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL
            $0.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR
            $0.storeOp = VK_ATTACHMENT_STORE_OP_STORE
            // fuckkkkkk
            $0.clearValue.color.float32 = (0.0, 0.0, 0.0, 0.1)
        }

        let renderingInfo = Box(VkRenderingInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_RENDERING_INFO
            $0.renderArea.extent.width = swapChain.extent.width
            $0.renderArea.extent.height = swapChain.extent.height
            $0.layerCount = 1
            $0.colorAttachmentCount = 1
            $0.pColorAttachments = colorAttachmentInfo.readonly
        }

        vkCmdBeginRendering(commandBuffer, renderingInfo.ptr)

        // Set viewport and scissor

        block(commandBuffer, swapChain)

        vkCmdEndRendering(commandBuffer)

        // Transition image to present
        let barrierPresent = Box(VkImageMemoryBarrier2()) {
            $0.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2
            $0.srcStageMask = VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT
            $0.srcAccessMask = VK_ACCESS_2_COLOR_ATTACHMENT_WRITE_BIT
            $0.dstStageMask = VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT
            $0.dstAccessMask = 0
            $0.oldLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
            $0.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
            $0.image = image
            $0.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT.rawValue
            $0.subresourceRange.levelCount = 1
            $0.subresourceRange.layerCount = 1
        }

        let barrierPresentDependencyInfo = Box(VkDependencyInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_DEPENDENCY_INFO
            $0.imageMemoryBarrierCount = 1
            $0.pImageMemoryBarriers = barrierPresent.readonly
        }

        vkCmdPipelineBarrier2(commandBuffer, barrierPresentDependencyInfo.ptr)

        vkEndCommandBuffer(commandBuffer).unwrap()

        // Submit
        let waitStages = Box(
            VkPipelineStageFlags(
                VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue))
        let presentSemaphore = Box(
            optional: swapChain.presentSemaphores[frameIndex])
        let renderSemaphore = Box(
            optional: swapChain.renderSemaphore[Int(imageIndex)])
        let commandBufferPtr = Box(optional: commandBuffer)

        let submitInfo = Box(VkSubmitInfo()) {
            $0.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
            $0.waitSemaphoreCount = 1
            // wont start rendering until current frame in presented
            $0.pWaitSemaphores = presentSemaphore.readonly
            $0.pWaitDstStageMask = waitStages.readonly
            $0.commandBufferCount = 1
            $0.pCommandBuffers = commandBufferPtr.readonly
            $0.signalSemaphoreCount = 1
            $0.pSignalSemaphores = renderSemaphore.readonly
        }

        vkQueueSubmit(state.graphicsQueue, 1, submitInfo.ptr, swapChain.fences[frameIndex])
            .unwrap()
        // present

        let swapchainHandle: Box<VkSwapchainKHR?> = Box(swapChain.swapChain)
        let imageIndexCopy = Box(imageIndex)

        let presentInfo = Box(VkPresentInfoKHR()) {
            $0.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
            $0.waitSemaphoreCount = 1
            $0.pWaitSemaphores = renderSemaphore.readonly
            $0.swapchainCount = 1
            $0.pSwapchains = swapchainHandle.readonly
            $0.pImageIndices = imageIndexCopy.readonly
        }

        // should this be in the main queue tho
        vkQueuePresentKHR(state.presentQueue, presentInfo.ptr).unwrap()

        // recreate swapchain ????

        swapChain.frameIndex = (swapChain.frameIndex + 1) % swapChain.framesInFlightCount
        return true
    }
}
