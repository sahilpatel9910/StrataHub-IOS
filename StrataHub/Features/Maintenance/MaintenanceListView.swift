import SwiftUI

struct MaintenanceListView: View {
    @State private var viewModel = MaintenanceListViewModel()
    @State private var showingNewRequest = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroHeader(
                    eyebrow: "Maintenance",
                    title: "Requests",
                    subtitle: "Track repairs and maintenance for your unit."
                )

                AppPanel {
                    HStack {
                        StatCard(label: "Active", value: "\(viewModel.activeCount)", systemImage: "wrench.and.screwdriver.fill", tone: .info)
                        Spacer()
                        StatCard(
                            label: "Urgent",
                            value: "\(viewModel.urgentCount)",
                            systemImage: "exclamationmark.triangle.fill",
                            tone: viewModel.urgentCount > 0 ? .negative : .neutral
                        )
                        Spacer()
                        StatCard(label: "Completed", value: "\(viewModel.completedCount)", systemImage: "checkmark.circle.fill", tone: .positive)
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(systemImage: "exclamationmark.triangle", title: "Couldn't load requests", message: errorMessage)
                } else if viewModel.requests.isEmpty {
                    EmptyStateView(
                        systemImage: "wrench.and.screwdriver",
                        title: "No maintenance requests",
                        message: "File a request when something needs attention."
                    )
                } else {
                    ForEach(viewModel.requests) { request in
                        NavigationLink(value: request.id) {
                            AppPanel {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(request.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Theme.textPrimary)
                                        Spacer()
                                        StatusBadge(text: request.status.label, tone: request.status.badgeTone)
                                    }
                                    HStack(spacing: 4) {
                                        if let unit = request.unit {
                                            Text("Unit \(unit.unitNumber)")
                                            Text("·")
                                        }
                                        Text(request.category.label)
                                        Spacer()
                                        Text(request.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    }
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Maintenance")
        .navigationDestination(for: String.self) { requestId in
            MaintenanceDetailView(requestId: requestId)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewRequest = true
                } label: {
                    Label("New Request", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewRequest, onDismiss: {
            Task { await viewModel.load() }
        }) {
            NewMaintenanceRequestView()
        }
        .task {
            await viewModel.load()
        }
    }
}
