import SwiftUI
import Domain
import Application

public struct ProjectListView: View {
    @StateObject private var viewModel: ProjectListViewModel
    @State private var showingCreateProject = false

    public init(viewModel: ProjectListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
#if os(iOS)
                Color(uiColor: .systemGroupedBackground)
#else
                Color(nsColor: .windowBackgroundColor)
#endif
                    .ignoresSafeArea()

                VStack {
                    if viewModel.isLoading && viewModel.projects.isEmpty {
                        ProgressView("Loading projects...")
                            .scaleEffect(1.2)
                    } else if viewModel.projects.isEmpty {
                        emptyStateView
                    } else {
                        projectsList
                    }
                }
                .navigationTitle("PayPay")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCreateProject = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    }
                }
                .sheet(isPresented: $showingCreateProject) {
                    CreateProjectView { name, participants in
                        viewModel.createProject(name: name, participants: participants)
                    }
                }
                .alert("Error", isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .onAppear {
                    viewModel.fetchProjects()
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No Projects Yet")
                .font(.title2)
                .bold()
            Text("Create a project to start splitting bills and simplifying debts.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingCreateProject = true
            } label: {
                Text("Create First Project")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .indigo.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
        .padding()
    }

    private var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                NavigationLink(value: project) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(project.name)
                            .font(.headline)
                        HStack {
                            Label("\(project.participants.count) members", systemImage: "person.2.fill")
                            Spacer()
                            Label("\(project.expenses.count) expenses", systemImage: "cart.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationDestination(for: Project.self) { project in
            let repo = InMemoryProjectRepository()
            let simplifier = DebtSimplifier()
            let useCase = ExpenseUseCaseImpl(projectRepository: repo, debtSimplifier: simplifier)
            let detailVM = ProjectViewModel(
                project: project,
                addExpenseUseCase: useCase,
                calculateBalancesUseCase: useCase
            )
            ProjectDashboardView(viewModel: detailVM)
        }
    }
}
