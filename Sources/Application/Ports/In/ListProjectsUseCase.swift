import Foundation
import Domain

public protocol ListProjectsUseCase: Sendable {
    func execute() async throws -> [Project]
}
