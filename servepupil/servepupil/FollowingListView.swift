import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct FollowingListView: View {
    let uid: String
    @State private var following: [UserModel] = []

    var body: some View {
        List(following) { user in
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
        .navigationTitle("Following")
        .onAppear {
            fetchFollowing()
        }
    }

    func fetchFollowing() {
        let db = Database.database().reference()
        db.child("users").child(uid).child("following").observe(.value) { snapshot in
            var users: [UserModel] = []
            guard let dict = snapshot.value as? [String: Any] else {
                following = []
                return
            }

            let group = DispatchGroup()
            for followUid in dict.keys {
                group.enter()
                db.child("users").child(followUid).observeSingleEvent(of: .value) { snap in
                    if let userData = snap.value as? [String: Any] {
                        let user = UserModel(id: followUid, data: userData)
                        users.append(user)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                following = users
            }
        }
    }
}
