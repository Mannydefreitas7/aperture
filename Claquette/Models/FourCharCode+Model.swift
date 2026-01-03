import Foundation

extension FourCharCode: CustomStringConvertible {
    public var description: String {
        let chars: [Character] = [
            Character(UnicodeScalar((self >> 24) & 0xFF)!),
            Character(UnicodeScalar((self >> 16) & 0xFF)!),
            Character(UnicodeScalar((self >> 8) & 0xFF)!),
            Character(UnicodeScalar(self & 0xFF)!)
        ]
        return String(chars)
    }
}
