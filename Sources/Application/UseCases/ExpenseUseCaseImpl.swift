import Foundation
import Domain

public final class ExpenseUseCaseImpl: AddExpenseUseCase, CalculateBalancesUseCase {
    private let projectRepository: ProjectRepositoryProtocol
    private let debtSimplifier: DebtSimplifier

    public init(projectRepository: ProjectRepositoryProtocol, debtSimplifier: DebtSimplifier = DebtSimplifier()) {
        self.projectRepository = projectRepository
        self.debtSimplifier = debtSimplifier
    }

    public func execute(
        projectId: String,
        description: String,
        amount: Double,
        paidBy: String,
        splits: [String: Double]
    ) async throws -> Project {
        guard let project = try await projectRepository.getProject(id: projectId) else {
            throw NSError(domain: "ExpenseUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "Project not found"])
        }

        let expense = Expense(
            description: description,
            amount: amount,
            paidBy: paidBy,
            splits: splits
        )
        
        var updatedExpenses = project.expenses
        updatedExpenses.append(expense)

        let updatedProject = Project(
            id: project.id,
            name: project.name,
            participants: project.participants,
            expenses: updatedExpenses
        )

        try await projectRepository.saveProject(updatedProject)
        return updatedProject
    }

    public func calculateBalances(projectId: String) async throws -> [String: Double] {
        guard let project = try await projectRepository.getProject(id: projectId) else {
            throw NSError(domain: "ExpenseUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "Project not found"])
        }
        return debtSimplifier.calculateBalances(for: project)
    }

    public func simplifyDebts(projectId: String) async throws -> [Transaction] {
        guard let project = try await projectRepository.getProject(id: projectId) else {
            throw NSError(domain: "ExpenseUseCase", code: 404, userInfo: [NSLocalizedDescriptionKey: "Project not found"])
        }
        return debtSimplifier.simplifyDebts(in: project)
    }
}
