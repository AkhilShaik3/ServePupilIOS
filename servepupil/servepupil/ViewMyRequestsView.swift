import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct ViewMyRequestsView: View {
    @State private var myRequests: [RequestModel] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("servepupillogo")
                        .resizable()
                        .frame(width: 40, height: 30)
                    Spacer()
                }
                .padding(.horizontal)

                Text("My Requests")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                ForEach(myRequests) { request in
                    RequestCardView(request: request)
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
            var loadedRequests: [RequestModel] = []

            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any],
                   let request = RequestModel(id: child.key, data: data) {
                    loadedRequests.append(request)
                }
            }

            DispatchQueue.main.async {
                self.myRequests = loadedRequests
            }
        }
    }
}

struct RequestCardView: View {
    let request: RequestModel

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
            }

            HStack(spacing: 20) {
                Button("Edit") {
                    // To be implemented
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Delete") {
                    // To be implemented
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
    }
}
