import Foundation

public struct User: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let email: String

    public init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
