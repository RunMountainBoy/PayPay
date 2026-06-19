import Foundation

public struct Transaction: Equatable, Sendable {
    public let from: String // Debtor Participant ID
    public let to: String   // Creditor Participant ID
    public let amount: Double

    public init(from: String, to: String, amount: Double) {
        self.from = from
        self.to = to
        self.amount = amount
    }
}
