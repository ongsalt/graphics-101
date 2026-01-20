import Glibc

final class CString {
    var swiftString: String {
        didSet {
            var cStr = swiftString.cString(using: .utf8)!

            buffer = realloc(buffer, cStr.count * MemoryLayout<CChar>.size)
                .assumingMemoryBound(to: CChar.self)
            strcpy(buffer, &cStr)
        }
    }

    private(set) var buffer: UnsafeMutablePointer<CChar>
    var ptr: UnsafePointer<CChar> {
        UnsafePointer(buffer)
    }

    init(_ value: String) {
        buffer = malloc(16).assumingMemoryBound(to: CChar.self)
        swiftString = value
    }

    func leak() {
        Unmanaged.passRetained(self)
    }


    func unleak() {
        Unmanaged.passUnretained(self).takeRetainedValue()
    }

    deinit {
        free(buffer)
    }
}

extension CString: ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
