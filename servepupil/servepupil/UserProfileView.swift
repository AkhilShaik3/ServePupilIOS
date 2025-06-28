import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseAuth

struct UserProfileView: View {
    let uid: String

    @State private var name = "User"
    @State private var phone = ""
    @State private var address = ""
    @State private var followers = 0
    @State private var following = 0
    @State private var profileImageUrl: String?

    @State private var isFollowing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let currentUid = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let imageUrl = profileImageUrl, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }

                Text(name)
                    .font(.title)
                    .bold()

                Text(phone)
                    .font(.body)

                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 40) {
                    VStack {
                        Text("\(followers)")
                            .font(.title3)
                            .bold()
                        Text("Followers")
                            .font(.caption)
                    }

                    VStack {
                        Text("\(following)")
                            .font(.title3)
                            .bold()
                        Text("Following")
                            .font(.caption)
                    }
                }
                .padding(.top, 8)

                Button(action: {
                    toggleFollowStatus()
                }) {
                    Text(isFollowing ? "Unfollow" : "Follow")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Report User") {
                    reportUser()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
            checkIfFollowing()
        }
        .onDisappear {
            let ref = Database.database().reference()
                .child("users")
                .child(currentUid)
                .child("following")
                .child(uid)
            ref.removeAllObservers()
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    func loadProfile() {
        let ref = Database.database().reference().child("users").child(uid)

        ref.observe(.value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                name = data["name"] as? String ?? "User"
                phone = data["phone"] as? String ?? ""
                address = data["address"] as? String ?? ""
                profileImageUrl = data["imageUrl"] as? String
            }
        }

        ref.child("followers").observe(.value) { snap in
            followers = Int(snap.childrenCount)
        }

        ref.child("following").observe(.value) { snap in
            following = Int(snap.childrenCount)
        }
    }

    func checkIfFollowing() {
        let ref = Database.database().reference()
            .child("users")
            .child(currentUid)
            .child("following")
            .child(uid)

        ref.observe(.value) { snapshot in
            isFollowing = snapshot.exists()
        }
    }

    func toggleFollowStatus() {
        let userRef = Database.database().reference().child("users")
        let currentUserFollowingRef = userRef.child(currentUid).child("following").child(uid)
        let viewedUserFollowersRef = userRef.child(uid).child("followers").child(currentUid)

        if isFollowing {
            currentUserFollowingRef.removeValue()
            viewedUserFollowersRef.removeValue()
            isFollowing = false
            followers = max(followers - 1, 0)
        } else {
            currentUserFollowingRef.setValue(true)
            viewedUserFollowersRef.setValue(true)
            isFollowing = true
            followers += 1
        }
    }

    func reportUser() {
        let reportRef = Database.database().reference()
            .child("reported_content")
            .child("users")
            .child(uid)

        reportRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                alertMessage = "User has already been reported."
                showAlert = true
            } else {
                reportRef.setValue(true) { error, _ in
                    if let error = error {
                        alertMessage = "Failed to report user: \(error.localizedDescription)"
                    } else {
                        alertMessage = "User reported successfully."
                    }
                    showAlert = true
                }
            }
        }
    }
}
