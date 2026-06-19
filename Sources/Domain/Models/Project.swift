import Foundation

public struct Project: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let participants: [Participant]
    public let expenses: [Expense]

    public init(
        id: String = UUID().uuidString,
        name: String,
        participants: [Participant],
        expenses: [Expense] = []
    ) {
        self.id = id
        self.name = name
        self.participants = participants
        self.expenses = expenses
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
}
