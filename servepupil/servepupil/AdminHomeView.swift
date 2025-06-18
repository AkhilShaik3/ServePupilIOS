import SwiftUI
import FirebaseAuth

struct AdminHomeView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("servepupillogo")
                    .resizable()
                    .frame(width: 80, height: 80)

                Text("Admin Home Page")
                    .font(.title)
                    .bold()

                NavigationLink(destination: UserListView()) {
                                    Text("View Users")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.teal)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }


                Button("View Reports") {
                    // Navigate to reports list
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("View Requests") {
                    // Navigate to requests list
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Logout") {
                    try? Auth.auth().signOut()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
        }
    }
}
