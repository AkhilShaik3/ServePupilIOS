import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct RequestCardView: View {
    let request: RequestModel
    var showEditDelete: Bool = false
    var onDelete: (() -> Void)? = nil  // ✅ callback for UI refresh

    @State private var username = ""
    @State private var likeCount = 0
    @State private var commentCount = 0
    @State private var likedByMe = false
    @State private var showReportAlert = false
    @State private var showDeleteConfirmation = false


    private let currentUid = Auth.auth().currentUser?.uid ?? ""
    private var isAdmin: Bool {
        Auth.auth().currentUser?.email == "admin@gmail.com"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
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

                VStack(spacing: 5) {
                    if !isAdmin {
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
                    } else {
                        HStack {
                            Image(systemName: "heart")
                            Text("\(likeCount)")
                        }
                        NavigationLink(destination: CommentsView(request: request)) {
                            HStack {
                                Image(systemName: "message")
                                Text("\(commentCount)")
                            }
                        }
                    }
                }
                .font(.subheadline)
            }

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

            if showEditDelete {
                HStack(spacing: 20) {
                    if !isAdmin {
                        Button("Edit") { }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }

                    Button("Delete") {
                        showDeleteConfirmation = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .alert("Confirm Delete", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            deleteRequest()
                        }
                    } message: {
                        Text("Are you sure you want to delete this request?")
                    }

                }
            } else {
                Button("Report Post") {
                    reportRequest()
                }
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
        .alert("Reported", isPresented: $showReportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This post has been successfully reported.")
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

    func reportRequest() {
        let reportRef = Database.database().reference()
            .child("reported_content")
            .child("requests")
            .child(request.id)

        reportRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                return
            } else {
                reportRef.setValue(true) { error, _ in
                    if error == nil {
                        showReportAlert = true
                    }
                }
            }
        }
    }

    func deleteRequest() {
        let requestRef = Database.database().reference()
            .child("requests")
            .child(request.ownerUid)
            .child(request.id)

        requestRef.removeValue()

        let reportRef = Database.database().reference()
            .child("reported_content")
            .child("requests")
            .child(request.id)

        reportRef.removeValue()

        // ✅ Notify parent view to refresh
        onDelete?()
    }
}
