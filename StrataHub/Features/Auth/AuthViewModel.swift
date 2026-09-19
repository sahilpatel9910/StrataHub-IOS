import Foundation

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var isSubmitting = false
    var errorMessage: String?

    func signIn() async {
        errorMessage = nil
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password."
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await SupabaseManager.shared.signIn(email: email, password: password)
        } catch {
            errorMessage = "Couldn't sign in. Check your email and password."
        }
    }
}
