import SwiftUI
import Firebase
import PhotosUI
import MapKit
import FirebaseAuth
struct CreateRequestView: View {
    @State private var description = ""
    @State private var requestType = ""
    @State private var place = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedImage: UIImage?
    @State private var imageItem: PhotosPickerItem?
    @State private var showSuccessAlert = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image("servepupillogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 30)
                Spacer()
            }
            .padding(.horizontal)

            Text("Create Request")
                .font(.title)
                .bold()

            Text("Upload Image")
                .font(.subheadline)

            PhotosPicker(selection: $imageItem, matching: .images) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
            }
            .onChange(of: imageItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }

            TextField("Enter description", text: $description)
                .textFieldStyle(.roundedBorder)

            TextField("Request type", text: $requestType)
                .textFieldStyle(.roundedBorder)

            TextField("Enter place", text: $place)
                .textFieldStyle(.roundedBorder)

            Map(coordinateRegion: $region)
                .frame(height: 150)
                .cornerRadius(8)

            Button("Submit") {
                createRequest()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .alert("Request Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()  // Go back to UserHomeView
            }
        } message: {
            Text("Your request has been submitted successfully.")
        }
    }

    func createRequest() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        let usersRef = Database.database().reference().child("users").child(uid)
        usersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let requestIdRef = Database.database().reference().child("requests").child(uid).childByAutoId()

                let requestData: [String: Any] = [
                    "description": description,
                    "requestType": requestType,
                    "place": place,
                    "latitude": region.center.latitude,
                    "longitude": region.center.longitude,
                    "timestamp": ServerValue.timestamp()
                ]

                requestIdRef.setValue(requestData) { error, _ in
                    if error == nil {
                        showSuccessAlert = true
                    } else {
                        print("Error saving request: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("User not found in users reference.")
            }
        }
    }
}
