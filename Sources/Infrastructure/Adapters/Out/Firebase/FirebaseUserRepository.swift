import Foundation
import Domain
import Application

public final class FirebaseUserRepository: UserRepositoryProtocol {
    public init() {}

    public func getUser(id: String) async throws -> User? {
        print("[Firebase] Fetching user with ID: \(id)")
        return nil
    }

    public func saveUser(_ user: User) async throws {
        print("[Firebase] Saving user: \(user.name) (ID: \(user.id))")
    }
}
