import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct CreateProfileView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var bio = ""
    @State private var phone = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""

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

                Text("Create Profile")
                    .font(.title)
                    .bold()

                Text("Upload your image")
                    .font(.subheadline)

                Button(action: {
                    showImagePicker = true
                }) {
                    if let image = selectedImage {
                        Image(uiImage: image)
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

                Group {
                    TextField("Enter name", text: $name)
                    TextField("Enter bio", text: $bio)
                    TextField("Enter phone number", text: $phone)
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                Button(action: {
                    saveProfile()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.teal)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference().child("users").child(uid)
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")

        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    alertMessage = "Image upload failed: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        alertMessage = "Failed to get download URL: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    if let url = url {
                        let user = UserModel(id: uid, data: [
                            "name": name,
                            "bio": bio,
                            "phone": phone,
                            "imageUrl": url.absoluteString,
                            "followers": 0,
                            "following": 0
                        ])
                        ref.setValue(user.toDict()) { error, _ in
                            if let error = error {
                                alertMessage = "Error saving data: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Profile saved successfully!"
                                dismiss()
                            }
                            showAlert = true
                        }
                    }
                }
            }
        } else {
            alertMessage = "Please select an image."
            showAlert = true
        }
    }
}
