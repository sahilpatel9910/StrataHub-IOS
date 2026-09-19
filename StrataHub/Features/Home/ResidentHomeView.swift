import SwiftUI

struct ResidentHomeView: View {
    @State private var viewModel = ResidentHomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if let profile = viewModel.profile {
                    if let unit = profile.primaryUnit {
                        HeroHeader(
                            eyebrow: "Resident Workspace",
                            title: "Welcome back, \(profile.firstName)",
                            subtitle: "Unit \(unit.unitNumber) — \(unit.building.name) · \(unit.building.suburb)"
                        )

                        AppPanel {
                            VStack(spacing: 16) {
                                StatCard(
                                    label: "Outstanding Balance",
                                    value: viewModel.outstandingBalanceCents.centsAsCurrency,
                                    systemImage: "dollarsign.circle.fill",
                                    tone: viewModel.outstandingBalanceCents > 0 ? .warning : .positive
                                )
                                Divider()
                                StatCard(
                                    label: "Open Requests",
                                    value: "\(viewModel.openMaintenanceCount) active",
                                    systemImage: "wrench.and.screwdriver.fill",
                                    tone: .info
                                )
                                Divider()
                                StatCard(
                                    label: "Announcements",
                                    value: "\(viewModel.liveAnnouncementsCount) live",
                                    systemImage: "megaphone.fill",
                                    tone: .neutral
                                )
                            }
                        }

                        AppPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Announcements").font(.headline)
                                if viewModel.recentAnnouncements.isEmpty {
                                    Text("No announcements at the moment")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textSecondary)
                                } else {
                                    ForEach(Array(viewModel.recentAnnouncements.enumerated()), id: \.element.id) { index, announcement in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(announcement.title).font(.subheadline.weight(.semibold))
                                            Text(announcement.content)
                                                .font(.footnote)
                                                .foregroundStyle(Theme.textSecondary)
                                                .lineLimit(2)
                                        }
                                        if index < viewModel.recentAnnouncements.count - 1 {
                                            Divider().padding(.vertical, 6)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        EmptyStateView(
                            systemImage: "building.2",
                            title: "No unit assigned yet",
                            message: "Contact your building manager to get linked to your unit."
                        )
                        .padding(.top, 60)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(
                        systemImage: "exclamationmark.triangle",
                        title: "Couldn't load your dashboard",
                        message: errorMessage
                    )
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign Out") {
                    Task { await SupabaseManager.shared.signOut() }
                }
                .font(.footnote)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
