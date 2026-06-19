import Foundation
import Domain

public protocol UserRepositoryProtocol: Sendable {
    func getUser(id: String) async throws -> User?
    func saveUser(_ user: User) async throws
}
