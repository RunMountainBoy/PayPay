import Foundation
import Domain
import Application

public final class FirebaseProjectRepository: ProjectRepositoryProtocol {
    public init() {}

    public func getProject(id: String) async throws -> Project? {
        print("[Firebase] Fetching project with ID: \(id)")
        return nil
    }

    public func saveProject(_ project: Project) async throws {
        print("[Firebase] Saving project: \(project.name) (ID: \(project.id))")
    }

    public func listProjects() async throws -> [Project] {
        print("[Firebase] Listing all projects")
        return []
    }
}
