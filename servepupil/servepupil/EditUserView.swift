import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct EditUserView: View {
    let user: UserModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var phone: String = ""
    @State private var imageUrl: String = ""
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

                Text("Edit User")
                    .font(.title)
                    .bold()

                Text("Change user image")
                    .font(.subheadline)

                Button(action: {
                    showImagePicker = true
                }) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 150)
                            .cornerRadius(10)
                    } else if let url = URL(string: imageUrl) {
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
                    updateUser()
                }) {
                    Text("Save Changes")
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
            Alert(title: Text("Update Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("success") {
                    dismiss()
                }
            })
        }
        .onAppear {
            observeUserData()
        }
    }

    func observeUserData() {
        let ref = Database.database().reference().child("users").child(user.id)
        ref.observe(.value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                name = data["name"] as? String ?? ""
                bio = data["bio"] as? String ?? ""
                phone = data["phone"] as? String ?? ""
                imageUrl = data["imageUrl"] as? String ?? ""
            }
        }
    }

    func updateUser() {
        let ref = Database.database().reference().child("users").child(user.id)
        let storageRef = Storage.storage().reference().child("profile_images/\(user.id).jpg")

        if let newImageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            storageRef.putData(newImageData, metadata: nil) { _, error in
                if let error = error {
                    alertMessage = "Image upload failed: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        alertMessage = "Image URL fetch failed: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    let updates: [String: Any] = [
                        "name": name,
                        "bio": bio,
                        "phone": phone,
                        "imageUrl": url?.absoluteString ?? ""
                    ]

                    ref.updateChildValues(updates) { error, _ in
                        alertMessage = error == nil ? "User updated successfully!" : "Update failed: \(error!.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        } else {
            let updates: [String: Any] = [
                "name": name,
                "bio": bio,
                "phone": phone
            ]

            ref.updateChildValues(updates) { error, _ in
                alertMessage = error == nil ? "User updated successfully!" : "Update failed: \(error!.localizedDescription)"
                showAlert = true
            }
        }
    }
}
