import SwiftUI
import Domain

struct CheckboxToggleStyle: ToggleStyle {
    let activeColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? activeColor : .gray)
                    .font(.title3)
                configuration.label
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

public struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    private let participants: [Participant]
    private let onAdd: (String, Double, String, [String: Double]) -> Void

    @State private var description = ""
    @State private var amountString = ""
    @State private var paidById = ""
    @State private var splitEqually = true
    @State private var selectedSplitParticipants: Set<String> = []

    // Neo-Finance colors
    private let slateDark = Color(red: 2/255, green: 6/255, blue: 23/255)
    private let cyanNeon = Color(red: 34/255, green: 211/255, blue: 238/255)
    private let greenNeon = Color(red: 74/255, green: 222/255, blue: 128/255)

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
            ZStack {
                slateDark
                    .ignoresSafeArea()

                ScrollView {
                    formContent
                }
            }
            .navigationTitle("Añadir Gasto")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(slateDark, for: .navigationBar)
#endif
            .toolbar {
                toolbarItems
            }
        }
    }

    private var formContent: some View {
        VStack(spacing: 20) {
            descriptionField
            amountField
            paidBySelector
            splitOptions
        }
        .padding()
    }

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descripción")
                .font(.caption.bold())
                .foregroundColor(.gray)
            TextField("Ej. Cena Italiana", text: $description)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monto ($)")
                .font(.caption.bold())
                .foregroundColor(.gray)
            HStack {
                Text("$")
                    .foregroundColor(cyanNeon)
                    .bold()
                TextField("0.00", text: $amountString)
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif
                    .foregroundColor(cyanNeon)
                    .font(.system(.body, design: .monospaced))
                    .monospacedDigit()
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }

    private var paidBySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pagado por")
                .font(.caption.bold())
                .foregroundColor(.gray)
            
            Picker("Quién pagó", selection: $paidById) {
                ForEach(participants) { participant in
                    Text(participant.name).tag(participant.id)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
            .frame(height: 50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .accentColor(cyanNeon)
        }
    }

    private var splitOptions: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $splitEqually) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dividir equitativamente")
                        .foregroundColor(.white)
                        .bold()
                    Text("El gasto se dividirá en partes iguales entre todos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: greenNeon))
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)

            if !splitEqually {
                customSplits
            }
        }
    }

    private var customSplits: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dividir entre:")
                .font(.caption.bold())
                .foregroundColor(.gray)

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
                .toggleStyle(CheckboxToggleStyle(activeColor: cyanNeon))
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") {
                dismiss()
            }
            .foregroundColor(.white)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Añadir") {
                addExpense()
            }
            .bold()
            .foregroundColor(greenNeon)
            .disabled(
                description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                Double(amountString) == nil ||
                (!splitEqually && selectedSplitParticipants.isEmpty)
            )
        }
    }

    private func addExpense() {
        guard let amount = Double(amountString), amount > 0 else { return }
        
        let splitTargets = splitEqually ? Set(participants.map { $0.id }) : selectedSplitParticipants
        guard !splitTargets.isEmpty else { return }
        
        let share = amount / Double(splitTargets.count)
        var splits: [String: Double] = [:]
        for participantId in splitTargets {
            splits[participantId] = share
        }

        onAdd(description, amount, paidById, splits)
        dismiss()
    }
}
