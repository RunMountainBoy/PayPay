import Foundation
import Combine
import Domain
import Application

@MainActor
public final class ProjectListViewModel: ObservableObject {
    @Published public var projects: [Project] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let listProjectsUseCase: ListProjectsUseCase
    private let createProjectUseCase: CreateProjectUseCase
    public let projectRepository: ProjectRepositoryProtocol
    public let debtSimplifier: DebtSimplifier

    public init(
        listProjectsUseCase: ListProjectsUseCase,
        createProjectUseCase: CreateProjectUseCase,
        projectRepository: ProjectRepositoryProtocol,
        debtSimplifier: DebtSimplifier
    ) {
        self.listProjectsUseCase = listProjectsUseCase
        self.createProjectUseCase = createProjectUseCase
        self.projectRepository = projectRepository
        self.debtSimplifier = debtSimplifier
    }

    public func fetchProjects() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                self.projects = try await listProjectsUseCase.execute()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    public func createProject(name: String, participants: [Participant]) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let newProject = try await createProjectUseCase.execute(name: name, participants: participants)
                self.projects.append(newProject)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
