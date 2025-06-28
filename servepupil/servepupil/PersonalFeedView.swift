import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseAuth

struct PersonalFeedView: View {
    @State private var personalRequests: [RequestModel] = []
    @State private var followedUids: Set<String> = []
    private let currentUid = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Personal Feed")
                    .font(.title)
                    .bold()

                if personalRequests.isEmpty {
                    Text("No requests found.")
                        .foregroundColor(.gray)
                }

                ForEach(personalRequests) { request in
                    RequestCardView(
                        request: request,
                        showEditDelete: request.ownerUid == currentUid,
                        onDelete: {
                            personalRequests.removeAll { $0.id == request.id }
                        }
                    )
                }
            }
            .padding()
        }
        .onAppear {
            observeFollowingList()
        }
    }

    func observeFollowingList() {
        let followRef = Database.database().reference().child("users").child(currentUid).child("following")
        
        followRef.observe(.value) { snapshot in
            let newUids = (snapshot.value as? [String: Any])?.keys.map { String($0) } ?? []
            let newFollowedSet = Set(newUids)

            // Detect unfollows (remove their requests)
            let unfollowed = followedUids.subtracting(newFollowedSet)
            if !unfollowed.isEmpty {
                personalRequests.removeAll { unfollowed.contains($0.ownerUid) }
            }

            followedUids = newFollowedSet
            observeRequestsFromFollowedUsers()
        }
    }

    func observeRequestsFromFollowedUsers() {
        let requestRef = Database.database().reference().child("requests")
        personalRequests.removeAll()

        for uid in followedUids {
            requestRef.child(uid).observe(.value) { snapshot in
                var newRequests: [RequestModel] = []

                if snapshot.exists() {
                    for child in snapshot.children {
                        if let snap = child as? DataSnapshot,
                           let data = snap.value as? [String: Any],
                           let request = RequestModel(id: snap.key, data: data, ownerUid: uid) {
                            newRequests.append(request)
                        }
                    }
                }

                // Remove all old requests from this user and add updated ones
                personalRequests.removeAll { $0.ownerUid == uid }
                personalRequests.append(contentsOf: newRequests)
            }
        }
    }
}
