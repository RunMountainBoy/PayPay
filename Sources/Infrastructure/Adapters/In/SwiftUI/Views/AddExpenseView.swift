import SwiftUI
import Domain

public struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    private let participants: [Participant]
    private let onAdd: (String, Double, String, [String: Double]) -> Void

    @State private var description = ""
    @State private var amountString = ""
    @State private var paidById = ""
    @State private var selectedSplitParticipants: Set<String> = []

    public init(participants: [Participant], onAdd: @escaping (String, Double, String, [String: Double]) -> Void) {
        self.participants = participants
        self.onAdd = onAdd
        
        if let first = participants.first {
            _paidById = State(initialValue: first.id)
        }
        
        _selectedSplitParticipants = State(initialValue: Set(participants.map { $0.id }))
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Expense Info")) {
                    TextField("Description (e.g. Dinner)", text: $description)
                    TextField("Amount ($)", text: $amountString)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Paid By")) {
                    Picker("Who paid?", selection: $paidById) {
                        ForEach(participants) { participant in
                            Text(participant.name).tag(participant.id)
                        }
                    }
                }

                Section(header: Text("Split Equally Between")) {
                    ForEach(participants) { participant in
                        Toggle(participant.name, isOn: Binding(
                            get: { selectedSplitParticipants.contains(participant.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSplitParticipants.insert(participant.id)
                                } else {
                                    selectedSplitParticipants.remove(participant.id)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExpense()
                    }
                    .disabled(
                        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        Double(amountString) == nil ||
                        selectedSplitParticipants.isEmpty
                    )
                }
            }
        }
    }

    private func addExpense() {
        guard let amount = Double(amountString), amount > 0 else { return }
        
        let share = amount / Double(selectedSplitParticipants.count)
        var splits: [String: Double] = [:]
        for participantId in selectedSplitParticipants {
            splits[participantId] = share
        }

        onAdd(description, amount, paidById, splits)
        dismiss()
    }
}
