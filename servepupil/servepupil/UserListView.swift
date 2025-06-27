import SwiftUI
import FirebaseDatabase
import SDWebImageSwiftUI

struct UserListView: View {
    @State private var users: [UserModel] = []
    @State private var blockedUserIds: Set<String> = []
    private var usersRef = Database.database().reference().child("users")

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

                            // ✅ Always show edit button
                            NavigationLink(destination: EditUserView(user: user)) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Users List")
            .onAppear {
                observeUsers()
            }
        }
    }

    func observeUsers() {
        usersRef.observe(.value) { snapshot in
            var tempUsers: [UserModel] = []
            var tempBlocked: Set<String> = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let data = snap.value as? [String: Any] {
                    let user = UserModel(id: snap.key, data: data)
                    tempUsers.append(user)

                    if let isBlocked = data["isBlocked"] as? Bool, isBlocked {
                        tempBlocked.insert(snap.key)
                    }
                }
            }

            self.users = tempUsers
            self.blockedUserIds = tempBlocked
        }
    }

    func toggleBlock(for user: UserModel) {
        let ref = usersRef.child(user.id).child("isBlocked")
        let newStatus = !blockedUserIds.contains(user.id)
        ref.setValue(newStatus)
    }
}
