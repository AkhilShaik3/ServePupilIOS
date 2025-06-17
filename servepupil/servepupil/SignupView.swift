import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var signupSuccess = false
    @State private var goToLogin = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo
                Image("servepupillogo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

                // Title
                Text("SignUp")
                    .font(.largeTitle)
                    .bold()

                // Email
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                // Password
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                // Confirm Password
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                // Signup Button
                Button(action: {
                    signup()
                }) {
                    Text("Signup")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Already have an account
                NavigationLink(destination: LoginView()) {
                    Text("Already have an account? Login")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }

                // Programmatic navigation after success
                NavigationLink(destination: LoginView(), isActive: $goToLogin) {
                    EmptyView()
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if signupSuccess {
                            goToLogin = true
                        }
                    }
                )
            }
        }
        .navigationBarHidden(true)
    }

    // Signup Function
    func signup() {
        // Basic email format check
        if !email.contains("@") || !email.contains(".") || email.count < 5 {
            alertMessage = "Please enter a valid email address."
            signupSuccess = false
            showAlert = true
            return
        }

        // Password match check
        if password != confirmPassword {
            alertMessage = "Passwords do not match."
            signupSuccess = false
            showAlert = true
            return
        }

        // Firebase signup
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Signup failed: \(error.localizedDescription)"
                signupSuccess = false
                showAlert = true
            } else {
                alertMessage = "Signup successful!"
                signupSuccess = true
                showAlert = true
            }
        }
    }
}
