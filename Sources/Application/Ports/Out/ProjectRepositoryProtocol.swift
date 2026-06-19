import Foundation
import Domain

public protocol ProjectRepositoryProtocol: Sendable {
    func getProject(id: String) async throws -> Project?
    func saveProject(_ project: Project) async throws
    func listProjects() async throws -> [Project]
}
