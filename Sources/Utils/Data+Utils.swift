import Foundation

extension Data {
    func toCasID() -> String {
        "0~" + dropFirst()
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}
