//
//  ProfileRouterView.swift
//  servepupil
//
//  Created by Admin on 6/10/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileRouterView: View {
    @State private var profileExists = false
    @State private var checked = false

    var body: some View {
        Group {
            if checked {
                if profileExists {
                    ProfileView()
                } else {
                    CreateProfileView()
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear(perform: checkUserProfile)
    }

    func checkUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)

        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                profileExists = true
            }
            checked = true
        }
    }
}
