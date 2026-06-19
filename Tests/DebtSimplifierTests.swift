import Testing
@testable import Domain

struct DebtSimplifierTests {
    private let simplifier = DebtSimplifier()

    @Test
    func testThreeParticipantsWithSimpleDebts() {
        // Arrange: 3 participants
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let bob = Participant(id: "B", name: "Bob", email: "bob@example.com")
        let charlie = Participant(id: "C", name: "Charlie", email: "charlie@example.com")

        // Alice paid 30, split equally between Alice, Bob, and Charlie (10 each)
        let expense = Expense.splitEqually(
            description: "Dinner",
            amount: 30.0,
            paidBy: "A",
            participants: ["A", "B", "C"]
        )

        let project = Project(
            name: "Trip",
            participants: [alice, bob, charlie],
            expenses: [expense]
        )

        // Act
        let balances = simplifier.calculateBalances(for: project)
        let transactions = simplifier.simplifyDebts(in: project)

        // Assert Balances
        #expect(balances["A"] == 20.0)
        #expect(balances["B"] == -10.0)
        #expect(balances["C"] == -10.0)

        // Assert Simplified Transactions
        #expect(transactions.count == 2)
        
        let expectedTransactions = [
            Transaction(from: "B", to: "A", amount: 10.0),
            Transaction(from: "C", to: "A", amount: 10.0)
        ]
        
        // Since order might depend on sorting of equal elements, check containment
        #expect(transactions.contains(expectedTransactions[0]))
        #expect(transactions.contains(expectedTransactions[1]))
    }

    @Test
    func testThreeParticipantsWithCrossDebts() {
        // Arrange: 3 participants
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let bob = Participant(id: "B", name: "Bob", email: "bob@example.com")
        let charlie = Participant(id: "C", name: "Charlie", email: "charlie@example.com")

        // 1. Alice paid 90, split equally between A, B, C (30 each)
        let expense1 = Expense.splitEqually(
            description: "Gas",
            amount: 90.0,
            paidBy: "A",
            participants: ["A", "B", "C"]
        )

        // 2. Bob paid 30, split equally between A, B, C (10 each)
        let expense2 = Expense.splitEqually(
            description: "Snacks",
            amount: 30.0,
            paidBy: "B",
            participants: ["A", "B", "C"]
        )

        let project = Project(
            name: "Weekend",
            participants: [alice, bob, charlie],
            expenses: [expense1, expense2]
        )

        // Act
        let balances = simplifier.calculateBalances(for: project)
        let transactions = simplifier.simplifyDebts(in: project)

        // Assert Balances:
        // A: +60 (exp1) - 10 (exp2) = +50
        // B: -30 (exp1) + 20 (exp2) = -10
        // C: -30 (exp1) - 10 (exp2) = -40
        #expect(balances["A"] == 50.0)
        #expect(balances["B"] == -10.0)
        #expect(balances["C"] == -40.0)

        // Assert Simplified Transactions:
        // C pays A 40
        // B pays A 10
        #expect(transactions.count == 2)
        #expect(transactions.contains(Transaction(from: "C", to: "A", amount: 40.0)))
        #expect(transactions.contains(Transaction(from: "B", to: "A", amount: 10.0)))
    }

    @Test
    func testFourParticipantsWithComplexCrossDebts() {
        // Arrange: 4 participants
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let bob = Participant(id: "B", name: "Bob", email: "bob@example.com")
        let charlie = Participant(id: "C", name: "Charlie", email: "charlie@example.com")
        let david = Participant(id: "D", name: "David", email: "david@example.com")

        // 1. Alice paid 100, split equally among A, B, C, D (25 each)
        let expense1 = Expense.splitEqually(
            description: "Rent",
            amount: 100.0,
            paidBy: "A",
            participants: ["A", "B", "C", "D"]
        )

        // 2. Bob paid 60, split equally among A, B, C, D (15 each)
        let expense2 = Expense.splitEqually(
            description: "Groceries",
            amount: 60.0,
            paidBy: "B",
            participants: ["A", "B", "C", "D"]
        )

        // 3. Charlie paid 40, split equally among A, B, C, D (10 each)
        let expense3 = Expense.splitEqually(
            description: "Utilities",
            amount: 40.0,
            paidBy: "C",
            participants: ["A", "B", "C", "D"]
        )

        let project = Project(
            name: "Apartment",
            participants: [alice, bob, charlie, david],
            expenses: [expense1, expense2, expense3]
        )

        // Act
        let balances = simplifier.calculateBalances(for: project)
        let transactions = simplifier.simplifyDebts(in: project)

        // Net Balances calculations:
        // A: +75 - 15 - 10 = +50.0
        // B: -25 + 45 - 10 = +10.0
        // C: -25 - 15 + 30 = -10.0
        // D: -25 - 15 - 10 = -50.0
        #expect(balances["A"] == 50.0)
        #expect(balances["B"] == 10.0)
        #expect(balances["C"] == -10.0)
        #expect(balances["D"] == -50.0)

        // Expected transactions:
        // D pays A 50
        // C pays B 10
        #expect(transactions.count == 2)
        #expect(transactions.contains(Transaction(from: "D", to: "A", amount: 50.0)))
        #expect(transactions.contains(Transaction(from: "C", to: "B", amount: 10.0)))
    }

    @Test
    func testEmptyProjectNoExpenses() {
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let project = Project(name: "Empty", participants: [alice], expenses: [])

        let balances = simplifier.calculateBalances(for: project)
        let transactions = simplifier.simplifyDebts(in: project)

        #expect(balances["A"] == 0.0)
        #expect(transactions.isEmpty)
    }

    @Test
    func testBalancedExpensesNoTransactionsNeeded() {
        let alice = Participant(id: "A", name: "Alice", email: "alice@example.com")
        let bob = Participant(id: "B", name: "Bob", email: "bob@example.com")

        // Alice pays 10, split equally (5 each)
        let exp1 = Expense.splitEqually(description: "Coffee", amount: 10.0, paidBy: "A", participants: ["A", "B"])
        // Bob pays 10, split equally (5 each)
        let exp2 = Expense.splitEqually(description: "Tea", amount: 10.0, paidBy: "B", participants: ["A", "B"])

        let project = Project(name: "Balanced", participants: [alice, bob], expenses: [exp1, exp2])

        let balances = simplifier.calculateBalances(for: project)
        let transactions = simplifier.simplifyDebts(in: project)

        #expect(balances["A"] == 0.0)
        #expect(balances["B"] == 0.0)
        #expect(transactions.isEmpty)
    }
}
