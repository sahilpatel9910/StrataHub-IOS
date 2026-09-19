import Foundation

@Observable
final class MaintenanceListViewModel {
    var isLoading = true
    var errorMessage: String?
    var requests: [MaintenanceRequestSummary] = []

    private let openStatuses: Set<MaintenanceStatus> = [.submitted, .acknowledged, .inProgress, .awaitingParts, .scheduled]

    var activeCount: Int { requests.filter { openStatuses.contains($0.status) }.count }
    var urgentCount: Int { requests.filter { $0.priority == .urgent }.count }
    var completedCount: Int { requests.filter { $0.status == .completed || $0.status == .closed }.count }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            requests = try await TRPCClient.query("resident.getMyMaintenanceRequests")
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Couldn't load maintenance requests."
        }
        isLoading = false
    }
}
