import SwiftUI
import Firebase

struct ReportedUsersView: View {
    @State private var reportedUsers: [(uid: String, name: String, bio: String)] = []
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("Reported Users")
                .font(.title)
                .bold()
                .padding()

            if reportedUsers.isEmpty {
                Spacer()
                Text("No reported users.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(reportedUsers, id: \.uid) { user in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.bio)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Button("Block User") {
                            blockUser(uid: user.uid)
                        }
                        .foregroundColor(.red)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .onAppear {
            fetchReportedUsers()
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    func fetchReportedUsers() {
        let reportRef = Database.database().reference().child("reported_content/users")

        reportRef.observeSingleEvent(of: .value) { snapshot in
            var userList: [(String, String, String)] = []
            let group = DispatchGroup()

            for case let child as DataSnapshot in snapshot.children {
                let uid = child.key
                group.enter()

                let userRef = Database.database().reference().child("users").child(uid)
                userRef.observeSingleEvent(of: .value) { snap in
                    if let data = snap.value as? [String: Any] {
                        let name = data["name"] as? String ?? "Unknown"
                        let bio = data["bio"] as? String ?? "No bio available"
                        userList.append((uid, name, bio))
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.reportedUsers = userList
            }
        }
    }

    func blockUser(uid: String) {
        let userRef = Database.database().reference().child("users").child(uid)
        let reportRef = Database.database().reference().child("reported_content/users").child(uid)

        // 1. Set isBlocked = true
        userRef.child("isBlocked").setValue(true) { error, _ in
            if let error = error {
                alertMessage = "Failed to block user: \(error.localizedDescription)"
                showAlert = true
                return
            }

            // 2. Remove from reported_content
            reportRef.removeValue { error, _ in
                if error != nil {
                    alertMessage = "Failed to update report list."
                } else {
                    alertMessage = "User blocked successfully."
                    fetchReportedUsers() // Refresh the list
                }
                showAlert = true
            }
        }
    }
}
