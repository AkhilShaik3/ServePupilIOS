import SwiftUI
import Firebase
import FirebaseAuth

struct Comment: Identifiable, Equatable {
    let id: String
    let uid: String
    let text: String
    let timestamp: Double
    var userName: String
}

struct CommentsView: View {
    let request: RequestModel
    @State private var comments: [Comment] = []
    @State private var newComment = ""

    var isAdmin: Bool {
        Auth.auth().currentUser?.email == "admin@gmail.com"
    }

    var body: some View {
        VStack {
            if comments.isEmpty {
                Spacer()
                Text("No comments yet")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(comment.userName)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(formatTimestamp(comment.timestamp))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(comment.text)
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()

            if !isAdmin {
                HStack {
                    TextField("Enter comment", text: $newComment)
                        .textFieldStyle(.roundedBorder)

                    Button("Post") {
                        postComment()
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            } else {
                Text("Admins can only view comments.")
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Comments")
        .onAppear {
            observeComments()
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
            "text": newComment.trimmingCharacters(in: .whitespacesAndNewlines),
            "timestamp": ServerValue.timestamp()
        ]

        commentRef.setValue(data)
        newComment = ""
    }

    func observeComments() {
        let ref = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("comments")

        ref.observe(.value) { snapshot in
            var updated: [Comment] = []
            let dispatchGroup = DispatchGroup()

            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any],
                   let uid = data["uid"] as? String,
                   let text = data["text"] as? String,
                   let timestamp = data["timestamp"] as? Double {

                    dispatchGroup.enter()

                    Database.database().reference()
                        .child("users")
                        .child(uid)
                        .child("name")
                        .observeSingleEvent(of: .value) { nameSnap in
                            let name = nameSnap.value as? String ?? "Unknown"
                            let comment = Comment(id: child.key, uid: uid, text: text, timestamp: timestamp, userName: name)
                            updated.append(comment)
                            dispatchGroup.leave()
                        }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.comments = updated.sorted(by: { $0.timestamp > $1.timestamp })
            }
        }
    }

    func formatTimestamp(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
