import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseAuth

struct ViewOthersRequestsView: View {
    @State private var requests: [RequestModel] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Requests")
                    .font(.title)
                    .bold()

                ForEach(requests) { request in
                    RequestCardView(request: request, showEditDelete: false)
                }
            }
            .padding()
        }
        .onAppear {
            fetchAllRequests()
        }
    }

    func fetchAllRequests() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference().child("requests")
        ref.observeSingleEvent(of: .value) { snapshot in
            var allRequests: [RequestModel] = []

            for userSnap in snapshot.children {
                if let userNode = userSnap as? DataSnapshot {
                    for requestSnap in userNode.children {
                        if let reqSnap = requestSnap as? DataSnapshot,
                           let data = reqSnap.value as? [String: Any],
                           userNode.key != currentUid, // filter out own requests
                           let request = RequestModel(id: reqSnap.key, data: data, ownerUid: userNode.key) {
                            allRequests.append(request)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.requests = allRequests
            }
        }
    }
}
