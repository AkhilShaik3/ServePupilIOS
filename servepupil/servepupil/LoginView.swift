import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showUserHome = false
    @State private var showAdminHome = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("servepupillogo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .padding(.top, 10)
                }

                NavigationLink(destination: SignupView()) {
                    Text("Don't have an account? Signup")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $showUserHome, onDismiss: {
                clearFields()
            }) {
                UserHomeView()
            }
            .fullScreenCover(isPresented: $showAdminHome, onDismiss: {
                clearFields()
            }) {
                AdminHomeView()
            }
        }
        .navigationBarHidden(true)
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Login failed: \(error.localizedDescription)"
                showAlert = true
            } else {
                if email.lowercased() == "admin@gmail.com" {
                    showAdminHome = true
                } else {
                    showUserHome = true
                }
            }
        }
    }

    func clearFields() {
        email = ""
        password = ""
        alertMessage = ""
        showAlert = false
    }
}
