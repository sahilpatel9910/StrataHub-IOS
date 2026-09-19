import SwiftUI

struct AnnouncementsView: View {
    @State private var viewModel = AnnouncementsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroHeader(
                    eyebrow: "Building Updates",
                    title: "Announcements",
                    subtitle: "Stay current with news from your building manager."
                )

                AppPanel {
                    HStack {
                        StatCard(label: "Live", value: "\(viewModel.announcements.count)", systemImage: "megaphone.fill", tone: .info)
                        Spacer()
                        StatCard(
                            label: "Urgent",
                            value: "\(viewModel.urgentCount)",
                            systemImage: "exclamationmark.triangle.fill",
                            tone: viewModel.urgentCount > 0 ? .negative : .neutral
                        )
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(
                        systemImage: "exclamationmark.triangle",
                        title: "Couldn't load announcements",
                        message: errorMessage
                    )
                } else if viewModel.announcements.isEmpty {
                    EmptyStateView(
                        systemImage: "megaphone",
                        title: "No announcements",
                        message: "There's nothing new from your building right now."
                    )
                } else {
                    ForEach(viewModel.announcements) { announcement in
                        AppPanel {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(announcement.priority.badgeTone.background)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "bell.fill")
                                            .foregroundStyle(announcement.priority.badgeTone.foreground)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(announcement.title).font(.headline)
                                        StatusBadge(text: announcement.priority.label, tone: announcement.priority.badgeTone)
                                    }
                                    Spacer()
                                }

                                Text(announcement.content)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textPrimary)

                                HStack {
                                    if let author = announcement.author {
                                        Text("\(author.firstName) \(author.lastName)")
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                    Spacer()
                                    if let publishedAt = announcement.publishedAt {
                                        Text(publishedAt.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }

                                if let expiresAt = announcement.expiresAt {
                                    Text("Expires \(expiresAt.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Theme.warning)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Announcements")
        .task {
            await viewModel.load()
        }
    }
}
