import SwiftUI
import Domain
import Application

@main
public struct ExpensesApp: App {
    private let projectListVM: ProjectListViewModel

    public init() {
        let projectRepository = InMemoryProjectRepository()
        let simplifier = DebtSimplifier()
        
        let manageProjectUseCase = ManageProjectUseCaseImpl(projectRepository: projectRepository)
        
        self.projectListVM = ProjectListViewModel(
            listProjectsUseCase: manageProjectUseCase,
            createProjectUseCase: manageProjectUseCase
        )
    }

    public var body: some Scene {
        WindowGroup {
            ProjectListView(viewModel: projectListVM)
        }
    }
}
