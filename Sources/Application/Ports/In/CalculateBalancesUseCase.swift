import Foundation
import Domain

public protocol CalculateBalancesUseCase: Sendable {
    func calculateBalances(projectId: String) async throws -> [String: Double]
    func simplifyDebts(projectId: String) async throws -> [Transaction]
}
