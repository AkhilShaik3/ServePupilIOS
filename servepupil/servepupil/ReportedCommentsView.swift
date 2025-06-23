import SwiftUI
import Firebase

struct ReportedCommentsView: View {
    @State private var reportedComments: [Comment] = []
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("Reported Comments")
                .font(.title)
                .bold()
                .padding(.top)

            if reportedComments.isEmpty {
                Spacer()
                Text("No reported comments.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(reportedComments) { comment in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(comment.userName)
                                .bold()
                            Spacer()
                            Text(formatTimestamp(comment.timestamp))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text(comment.text)

                        Button("Delete") {
                            deleteComment(comment)
                        }
                        .foregroundColor(.red)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding()
        .onAppear {
            listenToReportedComments()
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    func listenToReportedComments() {
        let reportRef = Database.database().reference().child("reported_content/comments")

        // 🔁 Listen for live changes
        reportRef.observe(.value) { snapshot in
            var commentIDs: [String] = []

            for case let child as DataSnapshot in snapshot.children {
                commentIDs.append(child.key)
            }

            if commentIDs.isEmpty {
                self.reportedComments = []
            } else {
                fetchAllRequestsToMatchComments(commentIDs: commentIDs)
            }
        }
    }

    func fetchAllRequestsToMatchComments(commentIDs: [String]) {
        let requestsRef = Database.database().reference().child("requests")
        var fetchedComments: [Comment] = []
        let group = DispatchGroup()

        requestsRef.observeSingleEvent(of: .value) { snapshot in
            for case let userNode as DataSnapshot in snapshot.children {
                for case let reqNode as DataSnapshot in userNode.children {
                    let commentsRef = reqNode.childSnapshot(forPath: "comments")

                    for case let commNode as DataSnapshot in commentsRef.children {
                        if commentIDs.contains(commNode.key),
                           let data = commNode.value as? [String: Any],
                           let uid = data["uid"] as? String,
                           let text = data["text"] as? String,
                           let timestamp = data["timestamp"] as? Double {

                            group.enter()
                            fetchUserName(uid: uid) { name in
                                let comment = Comment(id: commNode.key, uid: uid, text: text, timestamp: timestamp, userName: name)
                                fetchedComments.append(comment)
                                group.leave()
                            }
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.reportedComments = fetchedComments
            }
        }
    }

    func fetchUserName(uid: String, completion: @escaping (String) -> Void) {
        let ref = Database.database().reference().child("users").child(uid).child("name")

        ref.observeSingleEvent(of: .value) { snapshot in
            let name = snapshot.value as? String ?? "Unknown"
            completion(name)
        }
    }

    func deleteComment(_ comment: Comment) {
        let requestsRef = Database.database().reference().child("requests")

        requestsRef.observeSingleEvent(of: .value) { snapshot in
            for case let userNode as DataSnapshot in snapshot.children {
                for case let reqNode as DataSnapshot in userNode.children {
                    let commentPath = "comments/\(comment.id)"
                    if reqNode.hasChild(commentPath) {
                        let commentRef = requestsRef
                            .child(userNode.key)
                            .child(reqNode.key)
                            .child("comments")
                            .child(comment.id)

                        commentRef.removeValue { error, _ in
                            if error != nil {
                                alertMessage = "Failed to delete comment."
                                showAlert = true
                                return
                            }

                            Database.database().reference()
                                .child("reported_content/comments")
                                .child(comment.id)
                                .removeValue { error, _ in
                                    if error != nil {
                                        alertMessage = "Failed to update report list."
                                    } else {
                                        alertMessage = "Comment deleted successfully."
                                    }
                                    showAlert = true
                                }
                        }

                        return
                    }
                }
            }

            alertMessage = "Failed to locate comment."
            showAlert = true
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
