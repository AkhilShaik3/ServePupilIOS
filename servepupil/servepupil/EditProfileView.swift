//
//  EditProfileView.swift
//  servepupil
//
//  Created by Admin on 6/11/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var bio = ""
    @State private var phone = ""
    @State private var imageUrl = ""
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

                Text("Edit Profile")
                    .font(.title)
                    .bold()

                Text("Change your image")
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
                    updateProfile()
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
            Alert(title: Text("Profile Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("success") {
                    dismiss()
                }
            })
        }
        .onAppear {
            fetchProfileData()
        }
    }

    func fetchProfileData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Database.database().reference().child("users").child(uid)
            .observeSingleEvent(of: .value) { snapshot in
                if let data = snapshot.value as? [String: Any] {
                    name = data["name"] as? String ?? ""
                    bio = data["bio"] as? String ?? ""
                    phone = data["phone"] as? String ?? ""
                    imageUrl = data["imageUrl"] as? String ?? ""
                }
            }
    }

    func updateProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")

        // If new image selected, upload first
        if let newImageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            storageRef.putData(newImageData, metadata: nil) { metadata, error in
                if let error = error {
                    alertMessage = "Image upload failed: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        alertMessage = "Failed to get image URL: \(error.localizedDescription)"
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
                        if let error = error {
                            alertMessage = "Update failed: \(error.localizedDescription)"
                        } else {
                            alertMessage = "Profile updated successfully!"
                        }
                        showAlert = true
                    }
                }
            }
        } else {
            // No new image, just update text data
            let updates: [String: Any] = [
                "name": name,
                "bio": bio,
                "phone": phone
            ]
            ref.updateChildValues(updates) { error, _ in
                if let error = error {
                    alertMessage = "Update failed: \(error.localizedDescription)"
                } else {
                    alertMessage = "Profile updated successfully!"
                }
                showAlert = true
            }
        }
    }
}
