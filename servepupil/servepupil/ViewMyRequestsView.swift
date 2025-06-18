import SwiftUI
import Firebase
import SDWebImageSwiftUI
import FirebaseAuth

struct ViewMyRequestsView: View {
    @State private var myRequests: [RequestModel] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("My Requests")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)

                ForEach(myRequests) { request in
                    RequestCardView(request: request, showEditDelete: true)
                }
            }
        }
        .onAppear {
            fetchMyRequests()
        }
    }

    func fetchMyRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference().child("requests").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            var loaded: [RequestModel] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let data = snap.value as? [String: Any],
                   let request = RequestModel(id: snap.key, data: data, ownerUid: uid) {
                    loaded.append(request)
                }
            }

            DispatchQueue.main.async {
                self.myRequests = loaded
            }
        }
    }
}
