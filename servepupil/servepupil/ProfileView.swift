import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileView: View {
    @State private var name = ""
    @State private var bio = ""
    @State private var phone = ""
    @State private var imageUrl: String = ""
    @State private var followers = 0
    @State private var following = 0
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Image("servepupillogo")
                        .resizable()
                        .frame(width: 40, height: 30)
                    Spacer()
                }
                .padding(.horizontal)

                Text("Profile")
                    .font(.title)
                    .bold()

                if isLoading {
                    ProgressView()
                } else {
                    if let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 150)
                                    .cornerRadius(10)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 200, height: 150)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                    }

                    Text(name)
                        .font(.title2)
                        .bold()

                    Text("Phone: \(phone)")
                        .font(.subheadline)

                    Text("Bio: \(bio)")
                        .font(.subheadline)

                    HStack(spacing: 40) {
                        VStack {
                            Text("\(followers)")
                                .bold()
                            Text("Followers")
                                .font(.caption)
                        }
                        VStack {
                            Text("\(following)")
                                .bold()
                            Text("Following")
                                .font(.caption)
                        }
                    }
                    .padding(.top, 10)

                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }


                    NavigationLink(destination: ChangePasswordView()) {
                        Text("Change Password")
                            .foregroundColor(.blue)
                            .font(.footnote)
                            .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchUserProfile()
        }
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                let user = UserModel(id: uid, data: data)
                name = user.name
                bio = user.bio
                phone = user.phone
                imageUrl = user.imageUrl
                followers = user.followers
                following = user.following
            }
            isLoading = false
        }
    }
}
