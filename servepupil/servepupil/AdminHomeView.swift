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


                NavigationLink(destination: ReportDashboardView()) {
                    Text("View Reports")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }


                Button("View Requests") {
                    // Navigate to requests list
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.teal)
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
