import Foundation
import Supabase

@Observable
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient
    private(set) var currentSession: Session?

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.url)!,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    var isAuthenticated: Bool { currentSession != nil }

    /// Call once at launch to pick up a session persisted from a previous run.
    func restoreSession() async {
        currentSession = try? await client.auth.session
    }

    @discardableResult
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        currentSession = session
        return session
    }

    func signOut() async {
        try? await client.auth.signOut()
        currentSession = nil
    }

    /// A valid access token, refreshed by the SDK first if it's near expiry.
    func validAccessToken() async throws -> String {
        let session = try await client.auth.session
        currentSession = session
        return session.accessToken
    }
}
