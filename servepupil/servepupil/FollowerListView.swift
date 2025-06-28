import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct FollowerListView: View {
    let uid: String
    @State private var followers: [UserModel] = []

    var body: some View {
        List(followers) { user in
            HStack(spacing: 16) {
                if let url = URL(string: user.imageUrl), !user.imageUrl.isEmpty {
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(Image(systemName: "person.fill"))
                }

                Text(user.name)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Followers")
        .onAppear {
            fetchFollowers()
        }
    }

    func fetchFollowers() {
        let db = Database.database().reference()
        db.child("users").child(uid).child("followers").observe(.value) { snapshot in
            var users: [UserModel] = []
            guard let dict = snapshot.value as? [String: Any] else {
                followers = []
                return
            }

            let group = DispatchGroup()
            for followerUid in dict.keys {
                group.enter()
                db.child("users").child(followerUid).observeSingleEvent(of: .value) { snap in
                    if let userData = snap.value as? [String: Any] {
                        let user = UserModel(id: followerUid, data: userData)
                        users.append(user)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                followers = users
            }
        }
    }
}
