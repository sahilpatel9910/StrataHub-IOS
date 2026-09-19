import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ResidentHomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                AnnouncementsView()
            }
            .tabItem { Label("Announcements", systemImage: "megaphone.fill") }

            NavigationStack {
                MaintenanceListView()
            }
            .tabItem { Label("Maintenance", systemImage: "wrench.and.screwdriver.fill") }
        }
        .tint(Theme.navy)
    }
}
