import Foundation

// To ensure main thread is not blocked
func launchCounter() -> Task<Void, any Error> {
    Task {
        var i = 0
        while !Task.isCancelled {
            print("[count] \(i) (\(Date.now))")
            i += 1
            try await Task.sleep(for: .seconds(1))
        }
    }
}
