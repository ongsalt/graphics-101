import Foundation

struct Logger {
    enum Tag {
        case vulkan
        case renderLoop
    }

    static func info(_ tag: Tag, _ message: String) {
        print("\(Date.now.formatFr()) [\(tag)] \(message)")
    }
}

private extension Date {
    func formatFr() -> String {
        // let time = (self.timeIntervalSince1970 - floor(self.timeIntervalSince1970)).formatted(.number)
        // return "\(self.ISO8601Format(.iso8601)) \(time)"
        "\(self.timeIntervalSince1970)"
    }
}