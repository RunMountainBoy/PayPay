#if os(iOS)
import Foundation
import Combine
import Domain
import Application

@MainActor
public final class ProjectViewModel: ObservableObject {
    @Published public var project: Project
    @Published public var balances: [String: Double] = [:]
    @Published public var simplifiedTransactions: [Transaction] = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let addExpenseUseCase: AddExpenseUseCase
    private let calculateBalancesUseCase: CalculateBalancesUseCase

    public init(
        project: Project,
        addExpenseUseCase: AddExpenseUseCase,
        calculateBalancesUseCase: CalculateBalancesUseCase
    ) {
        self.project = project
        self.addExpenseUseCase = addExpenseUseCase
        self.calculateBalancesUseCase = calculateBalancesUseCase
    }

    /// Convenience initializer to initialize with repositories and services directly
    public init(
        project: Project,
        repository: ProjectRepositoryProtocol,
        simplifier: DebtSimplifier
    ) {
        self.project = project
        let useCase = ExpenseUseCaseImpl(projectRepository: repository, debtSimplifier: simplifier)
        self.addExpenseUseCase = useCase
        self.calculateBalancesUseCase = useCase
    }

    public func loadBalancesAndTransactions() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let calculatedBalances = try await calculateBalancesUseCase.calculateBalances(projectId: project.id)
                let simplified = try await calculateBalancesUseCase.simplifyDebts(projectId: project.id)
                self.balances = calculatedBalances
                self.simplifiedTransactions = simplified
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    public func addExpense(description: String, amount: Double, paidBy: String, splits: [String: Double]) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let updatedProject = try await addExpenseUseCase.execute(
                    projectId: project.id,
                    description: description,
                    amount: amount,
                    paidBy: paidBy,
                    splits: splits
                )
                self.project = updatedProject
                loadBalancesAndTransactions()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
#endif
