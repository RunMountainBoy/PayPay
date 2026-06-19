import Foundation
import Domain

public protocol CreateProjectUseCase: Sendable {
    func execute(name: String, participants: [Participant]) async throws -> Project
}
