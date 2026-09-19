import Foundation

@Observable
final class ResidentHomeViewModel {
    var isLoading = true
    var errorMessage: String?

    var profile: ResidentProfile?
    var outstandingBalanceCents = 0
    var openMaintenanceCount = 0
    var liveAnnouncementsCount = 0
    var recentAnnouncements: [Announcement] = []

    private let outstandingStatuses: Set<PaymentStatus> = [.pending, .overdue, .partial]
    private let openMaintenanceStatuses: Set<MaintenanceStatus> = [.submitted, .acknowledged, .inProgress, .awaitingParts, .scheduled]

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let profileTask: ResidentProfile = TRPCClient.query("resident.getMyProfile")
            async let leviesTask: [Levy] = TRPCClient.query("resident.getMyLevies")
            async let billsTask: [CustomBill] = TRPCClient.query("customBills.getMyBills")
            async let requestsTask: [MaintenanceRequestSummary] = TRPCClient.query("resident.getMyMaintenanceRequests")
            async let announcementsTask: [Announcement] = TRPCClient.query("resident.getMyAnnouncements")

            let (profile, levies, bills, requests, announcements) =
                try await (profileTask, leviesTask, billsTask, requestsTask, announcementsTask)

            self.profile = profile

            let leviesOutstanding = levies.filter { outstandingStatuses.contains($0.status) }.reduce(0) { $0 + $1.amountCents }
            let billsOutstanding = bills.filter { outstandingStatuses.contains($0.status) }.reduce(0) { $0 + $1.amountCents }
            outstandingBalanceCents = leviesOutstanding + billsOutstanding

            openMaintenanceCount = requests.filter { openMaintenanceStatuses.contains($0.status) }.count
            liveAnnouncementsCount = announcements.count
            recentAnnouncements = Array(announcements.prefix(3))
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Something went wrong loading your dashboard."
        }
        isLoading = false
    }
}
