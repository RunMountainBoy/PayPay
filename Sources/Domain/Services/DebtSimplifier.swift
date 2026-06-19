import Foundation

public struct DebtSimplifier: Sendable {
    public init() {}

    /// Calculates the net balance for each participant in a project.
    /// A positive balance means the participant is owed money (creditor).
    /// A negative balance means the participant owes money (debtor).
    public func calculateBalances(for project: Project) -> [String: Double] {
        var balances: [String: Double] = [:]

        // Initialize balances for all participants to 0.0
        for participant in project.participants {
            balances[participant.id] = 0.0
        }

        // Accumulate expenses
        for expense in project.expenses {
            // The payer gets a positive credit for the full amount they paid
            balances[expense.paidBy, default: 0.0] += expense.amount

            // Each participant in the split owes their respective share (negative balance)
            for (participantId, share) in expense.splits {
                balances[participantId, default: 0.0] -= share
            }
        }

        return balances
    }

    /// Resolves and minimizes debts among participants in a project using a Greedy algorithm.
    /// Returns a list of transactions required to settle all debts.
    public func simplifyDebts(in project: Project) -> [Transaction] {
        let balances = calculateBalances(for: project)
        return simplify(balances: balances)
    }

    /// Internal logic to simplify debts from a raw balances dictionary.
    public func simplify(balances: [String: Double]) -> [Transaction] {
        // Epsilon tolerance to handle floating-point precision issues
        let epsilon = 0.0001

        struct Party {
            let id: String
            var balance: Double
        }

        var debtors: [Party] = []
        var creditors: [Party] = []

        for (id, balance) in balances {
            // Round to 2 decimal places to match standard currency values
            let roundedBalance = (balance * 100.0).rounded() / 100.0

            if roundedBalance < -epsilon {
                debtors.append(Party(id: id, balance: roundedBalance))
            } else if roundedBalance > epsilon {
                creditors.append(Party(id: id, balance: roundedBalance))
            }
        }

        var transactions: [Transaction] = []

        // Greedy resolution loop
        while !debtors.isEmpty && !creditors.isEmpty {
            // Sort debtors ascending (the one who owes the most, i.e., most negative, comes first)
            debtors.sort { $0.balance < $1.balance }
            // Sort creditors descending (the one who is owed the most, i.e., most positive, comes first)
            creditors.sort { $0.balance > $1.balance }

            let debtorIndex = 0
            let creditorIndex = 0

            let debtor = debtors[debtorIndex]
            let creditor = creditors[creditorIndex]

            let amountToTransfer = min(-debtor.balance, creditor.balance)

            // Round transfer amount to 2 decimal places
            let roundedTransfer = (amountToTransfer * 100.0).rounded() / 100.0

            if roundedTransfer > 0 {
                transactions.append(Transaction(from: debtor.id, to: creditor.id, amount: roundedTransfer))
            }

            // Update balances
            debtors[debtorIndex].balance += roundedTransfer
            creditors[creditorIndex].balance -= roundedTransfer

            // Remove settled parties
            if abs(debtors[debtorIndex].balance) < epsilon {
                debtors.remove(at: debtorIndex)
            }
            if abs(creditors[creditorIndex].balance) < epsilon {
                creditors.remove(at: creditorIndex)
            }
        }

        return transactions
    }
}
