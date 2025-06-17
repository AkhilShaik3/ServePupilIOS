import SwiftUI
import Firebase
import FirebaseAuth

struct Comment: Identifiable {
    let id: String
    let uid: String
    let text: String
    let timestamp: Double
    var userName: String = "Unknown"
}

struct CommentsView: View {
    let request: RequestModel
    @State private var comments: [Comment] = []
    @State private var newComment = ""

    var body: some View {
        VStack {
            List(comments) { comment in
                VStack(alignment: .leading) {
                    Text(comment.userName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(comment.text)
                }
            }

            HStack {
                TextField("Enter comment", text: $newComment)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    postComment()
                }
            }
            .padding()
        }
        .navigationTitle("Comments")
        .onAppear {
            fetchComments()
        }
    }

    func postComment() {
        guard let user = Auth.auth().currentUser else { return }

        let commentRef = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("comments")
            .childByAutoId()

        let data: [String: Any] = [
            "uid": user.uid,
            "text": newComment,
            "timestamp": ServerValue.timestamp()
        ]

        commentRef.setValue(data)
        newComment = ""
    }

    func fetchComments() {
        let ref = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("comments")

        ref.observe(.value) { snapshot in
            var temp: [Comment] = []

            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any],
                   let uid = data["uid"] as? String,
                   let text = data["text"] as? String,
                   let timestamp = data["timestamp"] as? Double {
                    var comment = Comment(id: child.key, uid: uid, text: text, timestamp: timestamp)

                    // Fetch username from users table
                    Database.database().reference()
                        .child("users")
                        .child(uid)
                        .child("name")
                        .observeSingleEvent(of: .value) { nameSnap in
                            if let name = nameSnap.value as? String {
                                comment.userName = name
                            }
                            DispatchQueue.main.async {
                                temp.append(comment)
                                comments = temp.sorted { $0.timestamp < $1.timestamp }
                            }
                        }
                }
            }
        }
    }
}
