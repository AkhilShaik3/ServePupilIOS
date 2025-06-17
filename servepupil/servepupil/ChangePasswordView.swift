//
//  ForgotPasswordView.swift
//  servepupil
//
//  Created by Admin on 6/9/25.
//


import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            Image("servepupillogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("Change Password")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 30)

            Button(action: {
                sendResetLink()
            }) {
                Text("Send reset link")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal)
                    .cornerRadius(8)
                    .padding(.horizontal, 30)
            }

            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func sendResetLink() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "A reset link has been sent to your email."
            }
            showAlert = true
        }
    }
}
