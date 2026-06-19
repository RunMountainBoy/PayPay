import SwiftUI
import Domain
import Application

public struct ProjectDetailView: View {
    @StateObject private var viewModel: ProjectDetailViewModel
    @State private var showingAddExpense = false
    @State private var selectedTab = 0

    public init(viewModel: ProjectDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Picker("View Selection", selection: $selectedTab) {
                Text("Expenses").tag(0)
                Text("Balances").tag(1)
                Text("Simplify").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $selectedTab) {
                expensesListTab
                    .tag(0)
                balancesTab
                    .tag(1)
                simplifyTab
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(viewModel.project.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(participants: viewModel.project.participants) { description, amount, paidBy, splits in
                viewModel.addExpense(description: description, amount: amount, paidBy: paidBy, splits: splits)
            }
        }
        .onAppear {
            viewModel.loadBalancesAndTransactions()
        }
    }

    private var expensesListTab: some View {
        List {
            if viewModel.project.expenses.isEmpty {
                Text("No expenses registered yet.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(viewModel.project.expenses) { expense in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(expense.description)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", expense.amount))
                                .bold()
                        }
                        HStack {
                            let payerName = viewModel.project.participants.first(where: { $0.id == expense.paidBy })?.name ?? "Unknown"
                            Text("Paid by \(payerName)")
                            Spacer()
                            Text("\(expense.splits.count) splits")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var balancesTab: some View {
        List {
            ForEach(viewModel.project.participants) { participant in
                let balance = viewModel.balances[participant.id] ?? 0.0
                HStack {
                    Text(participant.name)
                        .font(.body)
                    Spacer()
                    Text(String(format: "%@$%.2f", balance >= 0 ? "+" : "", balance))
                        .bold()
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
            }
        }
    }

    private var simplifyTab: some View {
        List {
            if viewModel.simplifiedTransactions.isEmpty {
                Text("All settled up! No transactions needed.")
                    .foregroundColor(.green)
                    .bold()
            } else {
                ForEach(viewModel.simplifiedTransactions, id: \.from) { transaction in
                    let debtor = viewModel.project.participants.first(where: { $0.id == transaction.from })?.name ?? "Unknown"
                    let creditor = viewModel.project.participants.first(where: { $0.id == transaction.to })?.name ?? "Unknown"
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(debtor) owes \(creditor)")
                                .font(.headline)
                            Text("Transfer money directly to settle up.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "$%.2f", transaction.amount))
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
