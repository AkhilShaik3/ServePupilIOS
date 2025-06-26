//
//  EditRequestView.swift
//  servepupil
//
//  Created by Admin on 6/25/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import MapKit
import PhotosUI
import CoreLocation

struct EditRequestView: View {
    var request: RequestModel

    @State private var description: String
    @State private var requestType: String
    @State private var place: String
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion
    @State private var selectedImage: UIImage?
    @State private var imageItem: PhotosPickerItem?
    @State private var existingImageUrl: String?

    @StateObject private var searchVM = SearchCompleterViewModel()
    @StateObject private var locationManager = LocationManager()

    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.dismiss) var dismiss

    init(request: RequestModel) {
        self.request = request
        _description = State(initialValue: request.description)
        _requestType = State(initialValue: request.requestType)
        _place = State(initialValue: request.place)
        _selectedCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: request.latitude, longitude: request.longitude))
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: request.latitude, longitude: request.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        _selectedImage = State(initialValue: nil)
        _imageItem = State(initialValue: nil)
        _existingImageUrl = State(initialValue: request.imageUrl)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Edit Request")
                    .font(.title).bold()

                PhotosPicker(selection: $imageItem, matching: .images) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    } else if let urlStr = existingImageUrl, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 150)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 150)
                            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
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

                TextField("Description", text: $description)
                    .textFieldStyle(.roundedBorder)

                TextField("Request Type", text: $requestType)
                    .textFieldStyle(.roundedBorder)

                TextField("Search Place", text: $place)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: place) { newValue in
                        searchVM.queryFragment = newValue
                    }

                if !searchVM.results.isEmpty {
                    List(searchVM.results, id: \.title) { result in
                        VStack(alignment: .leading) {
                            Text(result.title).fontWeight(.semibold)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle).font(.subheadline).foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            searchPlace(result)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    self.searchVM.results = []
                                }
                            }
                        }
                    }
                    .frame(height: 150)
                }

                Map(coordinateRegion: $region, annotationItems: [MapPinLocation(coordinate: selectedCoordinate)]) { pin in
                    MapMarker(coordinate: pin.coordinate)
                }
                .frame(height: 150)
                .cornerRadius(10)

                Button("Update Request") {
                    updateRequest()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .onReceive(locationManager.$userLocation) { location in
                if location == nil {
                    locationManager.manager.startUpdatingLocation()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    dismiss() // ✅ Go back on alert dismiss
                }
            )
        }
    }

    func searchPlace(_ completion: MKLocalSearchCompletion) {
        let search = MKLocalSearch(request: MKLocalSearch.Request(completion: completion))
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }

            DispatchQueue.main.async {
                self.selectedCoordinate = coordinate
                self.region.center = coordinate
                self.place = completion.title + (completion.subtitle.isEmpty ? "" : ", \(completion.subtitle)")
            }
        }
    }

    func updateRequest() {
        guard let user = Auth.auth().currentUser else { return }

        let uid = user.uid
        let requestRef = Database.database().reference().child("requests").child(uid).child(request.id)

        guard !description.isEmpty, !requestType.isEmpty, !place.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        func saveData(imageUrl: String?) {
            var updatedData: [String: Any] = [
                "description": description,
                "requestType": requestType,
                "place": place,
                "latitude": selectedCoordinate.latitude,
                "longitude": selectedCoordinate.longitude,
                "timestamp": ServerValue.timestamp()
            ]
            if let imageUrl = imageUrl {
                updatedData["imageUrl"] = imageUrl
            }

            requestRef.updateChildValues(updatedData) { error, _ in
                if let error = error {
                    alertMessage = "Update failed: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    alertMessage = "Request updated successfully."
                    showAlert = true
                }
            }
        }

        if let newImage = selectedImage,
           let imageData = newImage.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("request_images/\(request.id).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if error != nil {
                    alertMessage = "Image upload failed."
                    showAlert = true
                    return
                }
                storageRef.downloadURL { url, _ in
                    saveData(imageUrl: url?.absoluteString)
                }
            }
        } else {
            saveData(imageUrl: existingImageUrl)
        }
    }
}
