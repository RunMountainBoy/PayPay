import Foundation
import Domain

public final class ManageProjectUseCaseImpl: CreateProjectUseCase, ListProjectsUseCase {
    private let projectRepository: ProjectRepositoryProtocol

    public init(projectRepository: ProjectRepositoryProtocol) {
        self.projectRepository = projectRepository
    }

    public func execute(name: String, participants: [Participant]) async throws -> Project {
        let project = Project(name: name, participants: participants)
        try await projectRepository.saveProject(project)
        return project
    }

    public func execute() async throws -> [Project] {
        try await projectRepository.listProjects()
    }
}
