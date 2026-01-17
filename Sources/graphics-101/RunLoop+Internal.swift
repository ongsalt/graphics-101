import CoreFoundation
import Foundation

extension RunLoop {
    var currentCFRunLoop: CFRunLoop {
        let _cfRunLoopStorage = Mirror(reflecting: RunLoop.main, ).children.first {
            $0.label == "_cfRunLoopStorage"
        }!.value
        let rl = unsafeBitCast(_cfRunLoopStorage, to: CFRunLoop?.self)!
        return rl
    }

    func addEpollPort(fileDescriptor fd: Int32) {
                // while display.dispatch() != -1 {
        //     // RunLoop.current.limitDate(forMode: .default)
        // }

        // print("Done")

        // how do i interface with wayland shit tho

        // https://github.com/swiftlang/swift-corelibs-foundation/blob/8e01f9a71bf0138f0049671a6312dc59ceae371f/Sources/Foundation/RunLoop.swift#L83

        // let port = Port()


        // // rl.
        // // CFRunLoopAddSource(rl, CFRunLoopSource!, )
        // // RunLoop.main._add(source, forMode: .common)
        // var context = CFRunLoopSourceContext()

        // let allocator = CFAllocatorGetDefault()!
        // let source = CFRunLoopSourceCreate(allocator.takeRetainedValue(), 0, &context)!
        // allocator.release()

        // RunLoop.main.add(port, forMode: .default)
        // RunLoop.main.add(Port, forMode: RunLoop.Mode)
    }
}
