import Foundation
import Domain
import Application

public final class InMemoryProjectRepository: ProjectRepositoryProtocol, @unchecked Sendable {
    private var projects: [String: Project] = [:]
    private let queue = DispatchQueue(label: "InMemoryProjectRepository")

    public init() {}

    public func getProject(id: String) async throws -> Project? {
        queue.sync { projects[id] }
    }

    public func saveProject(_ project: Project) async throws {
        queue.sync {
            projects[project.id] = project
        }
    }

    public func listProjects() async throws -> [Project] {
        queue.sync { Array(projects.values) }
    }
}
