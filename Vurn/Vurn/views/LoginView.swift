import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    
    var body: some View {
        ZStack {
            // Background
            AppColors.darkGreen
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/Title
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(AppColors.accentYellow)
                    
                    Text("Vurn")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.lightGreen)
                    
                    Text("Track your gym journey")
                        .font(.title3)
                        .foregroundColor(AppColors.lightGreen.opacity(0.8))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.lightGreen)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(VurnTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.lightGreen)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(VurnTextFieldStyle())
                            .textContentType(.password)
                    }
                    
                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await authService.signIn(email: email, password: password)
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.darkGreen))
                                    .scaleEffect(0.8)
                            }
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accentYellow)
                        .foregroundColor(AppColors.darkGreen)
                        .cornerRadius(12)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    
                    // Sign Up Link
                    Button(action: {
                        isShowingSignUp = true
                    }) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(AppColors.lightGreen.opacity(0.8))
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.accentYellow)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView()
        }
    }
}

struct SignUpView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AppColors.darkGreen
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(AppColors.accentYellow)
                            
                            Text("Create Account")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.lightGreen)
                            
                            Text("Join the Vurn community")
                                .font(.subheadline)
                                .foregroundColor(AppColors.lightGreen.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                TextField("Choose a unique username", text: $username)
                                    .textFieldStyle(VurnTextFieldStyle())
                                    .autocapitalization(.none)
                                    .textContentType(.username)
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(VurnTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .textContentType(.emailAddress)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                SecureField("Create a password", text: $password)
                                    .textFieldStyle(VurnTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.lightGreen)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(VurnTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            // Error Message
                            if let errorMessage = authService.errorMessage {
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Password Validation
                            if !password.isEmpty && password != confirmPassword {
                                Text("Passwords don't match")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            
                            // Sign Up Button
                            Button(action: {
                                Task {
                                    let success = await authService.signUp(email: email, password: password, username: username)
                                    if success {
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.darkGreen))
                                            .scaleEffect(0.8)
                                    }
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.accentYellow)
                                .foregroundColor(AppColors.darkGreen)
                                .cornerRadius(12)
                            }
                            .disabled(authService.isLoading || !isFormValid)
                        }
                        .padding(.horizontal, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.lightGreen)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !username.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
}

// Custom Text Field Style
struct VurnTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.darkGreen.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.mediumGreen.opacity(0.5), lineWidth: 1)
            )
            .foregroundColor(AppColors.lightGreen)
            .font(.system(size: 16))
    }
}

#Preview {
    LoginView()
}