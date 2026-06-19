import Foundation
import Domain

public protocol AddExpenseUseCase: Sendable {
    func execute(
        projectId: String,
        description: String,
        amount: Double,
        paidBy: String,
        splits: [String: Double]
    ) async throws -> Project
}
