import SwiftUI
import PhotosUI

struct MaintenanceDetailView: View {
    @State private var viewModel: MaintenanceDetailViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(requestId: String) {
        _viewModel = State(initialValue: MaintenanceDetailViewModel(requestId: requestId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if let request = viewModel.request {
                    AppPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(request.title).font(.title3.weight(.semibold))
                                Spacer()
                                StatusBadge(text: request.status.label, tone: request.status.badgeTone)
                            }
                            Text("Unit \(request.unit.unitNumber) — \(request.unit.building.name)")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)

                            timelineView(current: request.status)

                            Divider()

                            Text("Description").font(.subheadline.weight(.semibold))
                            Text(request.description)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textPrimary)

                            HStack {
                                StatusBadge(text: request.category.label, tone: .neutral)
                                StatusBadge(text: request.priority.label, tone: request.priority.badgeTone)
                            }
                        }
                    }

                    AppPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Photos (\(request.images.count))").font(.headline)
                                Spacer()
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    if viewModel.isUploadingPhoto {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "camera.fill")
                                    }
                                }
                                .disabled(viewModel.isUploadingPhoto)
                            }

                            if let uploadError = viewModel.uploadErrorMessage {
                                Text(uploadError).font(.caption).foregroundStyle(Theme.negative)
                            }

                            if request.images.isEmpty {
                                Text("No photos yet")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(request.images) { image in
                                            if let displayUrl = image.displayUrl, let url = URL(string: displayUrl) {
                                                AsyncImage(url: url) { phase in
                                                    if let loadedImage = phase.image {
                                                        loadedImage.resizable().scaledToFill()
                                                    } else {
                                                        Rectangle().fill(Theme.neutralBackground)
                                                    }
                                                }
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    AppPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Updates (\(request.comments.count))").font(.headline)

                            ForEach(request.comments) { comment in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(comment.user.firstName) \(comment.user.lastName)")
                                        .font(.caption.weight(.semibold))
                                    Text(comment.content).font(.subheadline)
                                    Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Divider()
                            }

                            HStack {
                                TextField("Ask a question or provide more detail…", text: $viewModel.newComment)
                                    .textFieldStyle(.roundedBorder)
                                Button {
                                    Task { await viewModel.submitComment() }
                                } label: {
                                    if viewModel.isSubmittingComment {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "arrow.up.circle.fill")
                                    }
                                }
                                .disabled(viewModel.isSubmittingComment || viewModel.newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(systemImage: "exclamationmark.triangle", title: "Couldn't load this request", message: errorMessage)
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Request")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    await viewModel.uploadPhoto(image: image)
                }
                selectedPhotoItem = nil
            }
        }
    }

    @ViewBuilder
    private func timelineView(current: MaintenanceStatus) -> some View {
        let steps = MaintenanceStatus.timelineSteps
        if let currentIndex = steps.firstIndex(of: current) {
            HStack(spacing: 4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    Circle()
                        .fill(index <= currentIndex ? Theme.navy : Theme.neutralBackground)
                        .frame(width: 8, height: 8)
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(index < currentIndex ? Theme.navy : Theme.neutralBackground)
                            .frame(height: 2)
                    }
                }
            }
        } else {
            StatusBadge(text: current.label, tone: current.badgeTone)
        }
    }
}
