import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct UserProfileView: View {
    let uid: String

    @State private var name = "User"
    @State private var phone = ""
    @State private var address = ""
    @State private var followers = 0
    @State private var following = 0
    @State private var profileImageUrl: String?

    @State private var showAlert = false
    @State private var alertMessage = ""

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

                HStack(spacing: 30) {
                    VStack {
                        Text("\(followers)")
                            .bold()
                        Text("Followers")
                    }

                    VStack {
                        Text("\(following)")
                            .bold()
                        Text("Following")
                    }

                    Button("Follow") {}
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

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
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    func loadProfile() {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                name = data["name"] as? String ?? "User"
                phone = data["phone"] as? String ?? ""
                address = data["address"] as? String ?? ""
                followers = data["followers"] as? Int ?? 0
                following = data["following"] as? Int ?? 0
                profileImageUrl = data["imageUrl"] as? String
            }
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
