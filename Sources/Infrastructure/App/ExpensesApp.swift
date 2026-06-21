import SwiftUI
import Domain
import Application

@main
public struct ExpensesApp: App {
    // Singletons in memory during execution
    private let projectRepository = InMemoryProjectRepository()
    private let debtSimplifier = DebtSimplifier()

    public var body: some Scene {
        WindowGroup {
            let initialProject = Self.createMockProject()
            ProjectDashboardView(viewModel: ProjectViewModel(
                project: initialProject,
                repository: projectRepository,
                simplifier: debtSimplifier
            ))
            .preferredColorScheme(.dark) // Force dark mode for 'Neo-Finance' style
            .task { @MainActor in
                try? await projectRepository.saveProject(initialProject)
            }
        }
    }

    // Helper to generate a default mock project for demo and testing purposes
    private static func createMockProject() -> Project {
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let bob = Participant(id: "B", name: "Bob", email: "bob@example.com")
        let charlie = Participant(id: "C", name: "Charlie", email: "charlie@example.com")
        
        let expense1 = Expense.splitEqually(
            description: "Cena de Bienvenida",
            amount: 90.0,
            paidBy: "A",
            participants: ["A", "B", "C"]
        )
        
        let expense2 = Expense.splitEqually(
            description: "Boletos de Tren",
            amount: 120.0,
            paidBy: "B",
            participants: ["A", "B", "C"]
        )

        return Project(
            id: "default-project-id",
            name: "Viaje a Europa",
            participants: [alice, bob, charlie],
            expenses: [expense1, expense2]
        )
    }
}
