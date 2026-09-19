import SwiftUI

struct RootView: View {
    private let supabase = SupabaseManager.shared
    @State private var isRestoringSession = true

    var body: some View {
        Group {
            if isRestoringSession {
                ProgressView()
            } else if supabase.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .task {
            await supabase.restoreSession()
            isRestoringSession = false
        }
    }
}
