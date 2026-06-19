import SwiftUI
import Domain
import Application

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCardModifier())
    }
}

public struct ProjectDashboardView: View {
    @StateObject private var viewModel: ProjectDetailViewModel
    @State private var selectedCurrentUser: String = ""
    @State private var showingAddExpenseSheet = false

    // Neo-Finance color palette
    private let slateDark = Color(red: 2/255, green: 6/255, blue: 23/255)
    private let cyanNeon = Color(red: 34/255, green: 211/255, blue: 238/255)
    private let greenNeon = Color(red: 74/255, green: 222/255, blue: 128/255)
    private let redNeon = Color(red: 248/255, green: 113/255, blue: 113/255)

    public init(viewModel: ProjectDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            slateDark
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Top user selector for interactive balance checks
                if !viewModel.project.participants.isEmpty {
                    HStack {
                        Text("Viendo como:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Picker("Usuario", selection: $selectedCurrentUser) {
                            ForEach(viewModel.project.participants) { participant in
                                Text(participant.name).tag(participant.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(cyanNeon)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }

                // Callout net balance card
                netBalanceCard
                    .padding(.horizontal)

                // Recent Expenses Section
                expensesSection
                    .padding(.horizontal)

                // Optimized Settlement Transactions
                settlementsSection
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top)

            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingAddExpenseSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title.bold())
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(greenNeon)
                            .clipShape(Circle())
                            .shadow(color: greenNeon.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle(viewModel.project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(slateDark, for: .navigationBar)
        .sheet(isPresented: $showingAddExpenseSheet) {
            AddExpenseView(participants: viewModel.project.participants) { description, amount, paidBy, splits in
                viewModel.addExpense(description: description, amount: amount, paidBy: paidBy, splits: splits)
            }
        }
        .onAppear {
            viewModel.loadBalancesAndTransactions()
            if selectedCurrentUser.isEmpty, let first = viewModel.project.participants.first {
                selectedCurrentUser = first.id
            }
        }
        .onChange(of: viewModel.project.participants) { participants in
            if selectedCurrentUser.isEmpty, let first = participants.first {
                selectedCurrentUser = first.id
            }
        }
    }

    private var netBalanceCard: some View {
        let balance = viewModel.balances[selectedCurrentUser] ?? 0.0
        
        return VStack(spacing: 8) {
            Text("BALANCE NETO")
                .font(.caption.bold())
                .foregroundColor(.gray)
                .tracking(1.5)
            
            Text(String(format: "%@$%.2f", balance >= 0 ? "+" : "-", abs(balance)))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(balance >= 0 ? greenNeon : redNeon)
            
            Text(balance >= 0 ? "Te deben dinero" : "Debes dinero")
                .font(.subheadline.bold())
                .foregroundColor(balance >= 0 ? greenNeon.opacity(0.8) : redNeon.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(balance >= 0 ? greenNeon.opacity(0.3) : redNeon.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(color: (balance >= 0 ? greenNeon : redNeon).opacity(0.15), radius: 15, x: 0, y: 8)
    }

    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gastos Recientes")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.project.expenses.isEmpty {
                Text("No hay gastos registrados.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .glassCard()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(viewModel.project.expenses) { expense in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(expense.description)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                    let payerName = viewModel.project.participants.first(where: { $0.id == expense.paidBy })?.name ?? "Alguien"
                                    Text("Pagado por \(payerName)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text(String(format: "$%.2f", expense.amount))
                                    .font(.system(.body, design: .monospaced))
                                    .monospacedDigit()
                                    .foregroundColor(cyanNeon)
                                    .bold()
                            }
                            .glassCard()
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }

    private var settlementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reparto Óptimo")
                .font(.headline)
                .foregroundColor(.white)
            
            if viewModel.simplifiedTransactions.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(greenNeon)
                    Text("¡Todos están al día!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .glassCard()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.simplifiedTransactions, id: \.from) { transaction in
                        let debtor = viewModel.project.participants.first(where: { $0.id == transaction.from })?.name ?? "Desconocido"
                        let creditor = viewModel.project.participants.first(where: { $0.id == transaction.to })?.name ?? "Desconocido"
                        
                        HStack {
                            Text(debtor)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(cyanNeon)
                            
                            Text(creditor)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(String(format: "$%.2f", transaction.amount))
                                .font(.system(.body, design: .monospaced))
                                .monospacedDigit()
                                .foregroundColor(cyanNeon)
                                .bold()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(8)
                    }
                }
                .glassCard()
            }
        }
    }
}
