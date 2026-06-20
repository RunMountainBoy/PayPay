import SwiftUI
import Domain

public struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""
    @State private var participantName = ""
    @State private var participantEmail = ""
    @State private var participants: [Participant] = []

    public var onCreate: (String, [Participant]) -> Void

    public init(onCreate: @escaping (String, [Participant]) -> Void) {
        self.onCreate = onCreate
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Project Name (e.g. Europe Trip)", text: $projectName)
                } header: {
                    Text("Project Info")
                }

                Section {
                    TextField("Name", text: $participantName)
                    TextField("Email", text: $participantEmail)
#if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
#endif
                    
                    Button {
                        addParticipant()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Add Participant", systemImage: "person.badge.plus")
                            Spacer()
                        }
                    }
                    .disabled(participantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } header: {
                    Text("Add Participant")
                }

                if !participants.isEmpty {
                    Section {
                        ForEach(participants) { participant in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(participant.name)
                                        .font(.body)
                                    if !participant.email.isEmpty {
                                        Text(participant.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button {
                                    removeParticipant(participant)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } header: {
                        Text("Participants List (\(participants.count))")
                    }
                }
            }
            .navigationTitle("New Project")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(projectName, participants)
                        dismiss()
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || participants.isEmpty)
                }
            }
        }
    }

    private func addParticipant() {
        let name = participantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = participantEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let newParticipant = Participant(name: name, email: email)
        participants.append(newParticipant)
        
        participantName = ""
        participantEmail = ""
    }

    private func removeParticipant(_ participant: Participant) {
        participants.removeAll { $0.id == participant.id }
    }
}
