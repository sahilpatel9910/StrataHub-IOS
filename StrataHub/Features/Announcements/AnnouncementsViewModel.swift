import Foundation

@Observable
final class AnnouncementsViewModel {
    var isLoading = true
    var errorMessage: String?
    var announcements: [Announcement] = []

    var urgentCount: Int { announcements.filter { $0.priority == .urgent }.count }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            announcements = try await TRPCClient.query("resident.getMyAnnouncements")
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Couldn't load announcements."
        }
        isLoading = false
    }
}
