import SwiftUI

struct NewMaintenanceRequestView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var category: MaintenanceCategory = .other
    @State private var priority: Priority = .medium
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    @State private var unit: ResidentProfile.UnitWithBuilding?
    @State private var isLoadingUnit = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Unit") {
                    if isLoadingUnit {
                        ProgressView()
                    } else if let unit {
                        Text("Unit \(unit.unitNumber) — \(unit.building.name)")
                            .foregroundStyle(Theme.textSecondary)
                    } else {
                        Text("No unit found on your account").foregroundStyle(Theme.negative)
                    }
                }
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Category & Priority") {
                    Picker("Category", selection: $category) {
                        ForEach(MaintenanceCategory.allCases, id: \.self) { category in
                            Text(category.label).tag(category)
                        }
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.label).tag(priority)
                        }
                    }
                }
                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(Theme.negative)
                }
            }
            .navigationTitle("New Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                        }
                    }
                    .disabled(title.isEmpty || description.isEmpty || isSubmitting || unit == nil)
                }
            }
            .task {
                if let profile: ResidentProfile = try? await TRPCClient.query("resident.getMyProfile") {
                    unit = profile.primaryUnit
                }
                isLoadingUnit = false
            }
        }
    }

    private struct CreateInput: Encodable {
        let unitId: String
        let title: String
        let description: String
        let category: MaintenanceCategory
        let priority: Priority
    }

    private func submit() async {
        guard let unit else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await TRPCClient.mutate(
                "resident.createMaintenanceRequest",
                input: CreateInput(unitId: unit.id, title: title, description: description, category: category, priority: priority)
            )
            dismiss()
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Couldn't submit your request."
        }
    }
}
