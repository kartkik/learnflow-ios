import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    let onLoginSuccess: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header Logo & Branding
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 80, height: 80)
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                    }
                    
                    Text("LearnFlow")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("Welcome back! Sign in to continue learning.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 18) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(viewModel.emailError != nil ? AppTheme.danger : AppTheme.primary)
                            TextField("name@learnflow.com", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .disabled(viewModel.isLoading)
                        }
                        .padding(14)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.emailError != nil ? AppTheme.danger : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        if let emailError = viewModel.emailError {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(AppTheme.danger)
                        }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(viewModel.passwordError != nil ? AppTheme.danger : AppTheme.primary)
                            SecureField("Enter your password", text: $viewModel.password)
                                .disabled(viewModel.isLoading)
                        }
                        .padding(14)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.passwordError != nil ? AppTheme.danger : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        if let passwordError = viewModel.passwordError {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundColor(AppTheme.danger)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Error state display
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppTheme.danger)
                        Text(errorMessage)
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.danger)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.danger.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.login()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                                Text("Logging in...")
                            } else {
                                Text("Sign In")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: AppTheme.primary.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .disabled(viewModel.isLoading)
                    
                    // Quick Demo Credentials Button
                    Button(action: {
                        viewModel.fillDemoCredentials()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wand.and.stars")
                            Text("Auto-fill Demo Account")
                        }
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primary)
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onChange(of: viewModel.isLoggedIn) { _, newValue in
            if newValue {
                onLoginSuccess()
            }
        }
    }
}

#Preview {
    LoginView(
        viewModel: LoginViewModel(
            loginUseCase: LoginUseCase(authRepository: AuthRepository())
        ),
        onLoginSuccess: {}
    )
}
