//
//  UserListView.swift
//  servepupil
//
//  Created by Admin on 6/18/25.
//


import SwiftUI
import FirebaseDatabase
import SDWebImageSwiftUI

struct UserListView: View {
    @State private var users: [UserModel] = []
    @State private var blockedUserIds: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(users) { user in
                        HStack(alignment: .center, spacing: 12) {
                            if let url = URL(string: user.imageUrl), !user.imageUrl.isEmpty {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }



                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.bio)
                                    .font(.subheadline)
                                Text(user.phone)
                                    .font(.caption)
                            }

                            Spacer()

                            Button(action: {
                                toggleBlock(for: user)
                            }) {
                                Text(blockedUserIds.contains(user.id) ? "UnBlock" : "Block")
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(blockedUserIds.contains(user.id) ? Color.teal : Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Users List")
            .onAppear {
                fetchUsers()
            }
        }
    }

    func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value) { snapshot in
            var tempUsers: [UserModel] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let data = snap.value as? [String: Any] {
                    let user = UserModel(id: snap.key, data: data)
                    tempUsers.append(user)

                    // Example: Check for block status under each user
                    if let isBlocked = data["isBlocked"] as? Bool, isBlocked {
                        blockedUserIds.insert(snap.key)
                    }
                }
            }
            self.users = tempUsers
        }
    }

    func toggleBlock(for user: UserModel) {
        let ref = Database.database().reference().child("users").child(user.id).child("isBlocked")
        let newStatus = !blockedUserIds.contains(user.id)
        ref.setValue(newStatus)
        if newStatus {
            blockedUserIds.insert(user.id)
        } else {
            blockedUserIds.remove(user.id)
        }
    }
}
