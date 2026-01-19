import Wayland

extension String {
    func persist() -> UnsafePointer<CChar> {
        let cStr = self.cString(using: .utf8)!
        let p = UnsafeMutableBufferPointer<CChar>.allocate(capacity: cStr.count)
        p.initialize(from: cStr)
        
        return UnsafeBufferPointer(p).baseAddress!
    }
}