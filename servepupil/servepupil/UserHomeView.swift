import SwiftUI
import FirebaseAuth

struct UserHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Top row: back button + logo
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Image("splash_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .padding(.horizontal, 20)

                Text("User Home Page")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                VStack(spacing: 20) {
                    NavigationLink(destination: ProfileRouterView()) {
                        Text("Profile")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .cornerRadius(10)
                    }


                    NavigationLink(destination: CreateRequestView()) {
                        HomeButton(title: "Create Request")
                    }

                    NavigationLink(destination: ViewOthersRequestsView()) {
                        HomeButton(title: "View Others Requests")
                    }

                    NavigationLink(destination: ViewMyRequestsView()) {
                        HomeButton(title: "View My Requests")
                    }

                    Button(action: {
                        logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    func logout() {
            do {
                try Auth.auth().signOut()
                dismiss()
            } catch {
                print("Logout failed: \(error.localizedDescription)")
            }
        }

    
}

struct HomeButton: View {
    let title: String

    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .cornerRadius(10)
    }
}
