import CoreFoundation
import Foundation
import Wayland

extension RunLoop {
    var currentCFRunLoop: CFRunLoop {
        let _cfRunLoopStorage = Mirror(reflecting: RunLoop.main, ).children.first {
            $0.label == "_cfRunLoopStorage"
        }!.value
        let rl = unsafeBitCast(_cfRunLoopStorage, to: CFRunLoop?.self)!
        return rl
    }

    func addEpollPort(fileDescriptor fd: Int32, perform: @escaping () -> Void) {
        struct Info {
            let fd: Int32
            let perform: () -> Void
        }

        let info = Box(Info(fd: fd, perform: perform))
        
        let infoPtr = Unmanaged.passRetained(info).toOpaque()

        var context = CFRunLoopSourceContext1(
            version: 1,
            info: infoPtr,
            retain: nil,
            release: nil,
            copyDescription: { info in
                print("what copy")
                // var c = "yeah no".cString(using: .utf8)!
                // CFStringCreateWithCString(
                //     kCFAllocatorSystemDefault, &c, UInt32(CFStringEncodings.UTF7.rawValue))
                // Unmanaged.passRetained()
                return nil
            },
            equal: { ptrA, ptrB in
                let a = Unmanaged<Box<Info>>.fromOpaque(ptrA!).takeUnretainedValue()
                let b = Unmanaged<Box<Info>>.fromOpaque(ptrB!).takeUnretainedValue()
                return a.value.fd == b.value.fd
            },
            hash: { infoPtr in
                let info = Unmanaged<Box<Info>>.fromOpaque(infoPtr!).takeUnretainedValue()
                return CFHashCode(bitPattern: info.value.fd.hashValue)
            },
            getPort: { infoPtr in
                let info = Unmanaged<Box<Info>>.fromOpaque(infoPtr!).takeUnretainedValue()
                return info.value.fd
            },
            perform: { infoPtr in
                let info = Unmanaged<Box<Info>>.fromOpaque(infoPtr!).takeUnretainedValue()
                info.value.perform()
            }
        )
        // print("Done")

        // how do i interface with wayland shit tho

        // https://github.com/swiftlang/swift-corelibs-foundation/blob/8e01f9a71bf0138f0049671a6312dc59ceae371f/Sources/Foundation/RunLoop.swift#L83

        // let port = Port()

        // // rl.
        // // CFRunLoopAddSource(rl, CFRunLoopSource!, )

        let source = withUnsafeMutablePointer(to: &context) { ptr in
            CFRunLoopSourceCreate(
                kCFAllocatorSystemDefault, 0, UnsafeMutablePointer(OpaquePointer(ptr)))!
        }

        CFRunLoopAddSource(self.currentCFRunLoop, source, kCFRunLoopCommonModes)

        // RunLoop.main.add(port, forMode: .default)
    }
}
