import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.navy)
                            .frame(width: 56, height: 56)
                        Image(systemName: "building.2.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .semibold))
                    }
                    Text("SECURE ACCESS")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(1.0)
                    Text("Welcome back")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Sign in to review announcements, maintenance, and day-to-day building activity.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)

                AppPanel {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email").font(.subheadline.weight(.medium))
                            TextField("you@example.com", text: $viewModel.email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password").font(.subheadline.weight(.medium))
                            SecureField("Enter your password", text: $viewModel.password)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit { Task { await viewModel.signIn() } }
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(Theme.negative)
                        }

                        Button {
                            Task { await viewModel.signIn() }
                        } label: {
                            HStack {
                                if viewModel.isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.navy)
                        .disabled(viewModel.isSubmitting)

                        Text("Access is invite-only. Ask your strata team for an invitation link, then return here to sign in.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Theme.background)
        .scrollDismissesKeyboard(.interactively)
    }
}
