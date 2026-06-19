import Foundation

public struct Expense: Identifiable, Equatable, Sendable {
    public let id: String
    public let description: String
    public let amount: Double
    public let paidBy: String // Participant ID
    public let splits: [String: Double] // Participant ID -> Share Amount

    public init(
        id: String = UUID().uuidString,
        description: String,
        amount: Double,
        paidBy: String,
        splits: [String: Double]
    ) {
        self.id = id
        self.description = description
        self.amount = amount
        self.paidBy = paidBy
        self.splits = splits
    }

    /// Convenience initializer for splitting an expense equally among a set of participants.
    /// Handles basic division of the total amount.
    public static func splitEqually(
        id: String = UUID().uuidString,
        description: String,
        amount: Double,
        paidBy: String,
        participants: [String]
    ) -> Expense {
        guard !participants.isEmpty else {
            return Expense(id: id, description: description, amount: amount, paidBy: paidBy, splits: [:])
        }

        let share = amount / Double(participants.count)
        var splits: [String: Double] = [:]
        for participantId in participants {
            splits[participantId] = share
        }

        return Expense(id: id, description: description, amount: amount, paidBy: paidBy, splits: splits)
    }
}
