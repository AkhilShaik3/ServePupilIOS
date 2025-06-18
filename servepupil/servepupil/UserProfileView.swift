//
//  UserProfileView.swift
//  servepupil
//
//  Created by Admin on 6/17/25.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct UserProfileView: View {
    let uid: String

    @State private var name = "User"
    @State private var phone = ""
    @State private var address = ""
    @State private var followers = 0
    @State private var following = 0
    @State private var profileImageUrl: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let imageUrl = profileImageUrl, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }

                Text(name)
                    .font(.title)
                    .bold()

                Text(phone)
                    .font(.body)

                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 30) {
                    VStack {
                        Text("\(followers)")
                            .bold()
                        Text("Followers")
                    }

                    VStack {
                        Text("\(following)")
                            .bold()
                        Text("Following")
                    }

                    Button("Follow") {}
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button("Report User") {}
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
        }
    }

    func loadProfile() {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                name = data["name"] as? String ?? "User"
                phone = data["phone"] as? String ?? ""
                address = data["address"] as? String ?? ""
                followers = data["followers"] as? Int ?? 0
                following = data["following"] as? Int ?? 0
                profileImageUrl = data["imageUrl"] as? String
            }
        }
    }
}
