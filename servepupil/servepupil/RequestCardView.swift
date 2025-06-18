import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct RequestCardView: View {
    let request: RequestModel
    var showEditDelete: Bool = false

    @State private var username = ""
    @State private var likeCount = 0
    @State private var commentCount = 0
    @State private var likedByMe = false

    private let currentUid = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Image
                if let imageUrl = request.imageUrl, let url = URL(string: imageUrl) {
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.description)
                        .fontWeight(.semibold)
                    Text(request.requestType)
                        .font(.subheadline)
                    Text(request.place)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Like + Comment
                VStack(spacing: 5) {
                    Button(action: toggleLike) {
                        HStack {
                            Image(systemName: likedByMe ? "heart.fill" : "heart")
                                .foregroundColor(likedByMe ? .red : .gray)
                            Text("\(likeCount)")
                        }
                    }

                    NavigationLink(destination: CommentsView(request: request)) {
                        HStack {
                            Image(systemName: "message")
                            Text("\(commentCount)")
                        }
                    }
                }
                .font(.subheadline)
            }

            // 👇 Username tap based on UID
            if request.ownerUid == currentUid {
                NavigationLink(destination: ProfileView()) {
                    Text(username)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top, 4)
                }
            } else {
                NavigationLink(destination: UserProfileView(uid: request.ownerUid)) {
                    Text(username)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top, 4)
                }
            }

            // Report or Edit/Delete
            if showEditDelete {
                HStack(spacing: 20) {
                    Button("Edit") { }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)

                    Button("Delete") { }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            } else {
                Button("Report Post") { }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
        .onAppear {
            fetchUsername()
            fetchLikeStatus()
            fetchCommentCount()
        }
    }

    func toggleLike() {
        let ref = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("likedBy")

        if likedByMe {
            ref.child(currentUid).removeValue()
        } else {
            ref.child(currentUid).setValue(true)
        }
    }

    func fetchLikeStatus() {
        let ref = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("likedBy")

        ref.observe(.value) { snapshot in
            likeCount = Int(snapshot.childrenCount)
            likedByMe = snapshot.hasChild(currentUid)
        }
    }

    func fetchCommentCount() {
        let ref = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)
            .child("comments")

        ref.observe(.value) { snapshot in
            commentCount = Int(snapshot.childrenCount)
        }
    }

    func fetchUsername() {
        let ref = Database.database().reference()
            .child("users")
            .child(request.ownerUid)
            .child("name")

        ref.observeSingleEvent(of: .value) { snapshot in
            if let name = snapshot.value as? String {
                self.username = name
            }
        }
    }
}
