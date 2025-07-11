import SwiftUI
import Firebase
import PhotosUI
import MapKit
import FirebaseAuth
import FirebaseStorage
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location fetch failed: \(error.localizedDescription)")
    }
}

struct CreateRequestView: View {
    @State private var description = ""
    @State private var requestType = ""
    @State private var place = ""
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @StateObject private var searchVM = SearchCompleterViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedImage: UIImage?
    @State private var imageItem: PhotosPickerItem?

    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 15) {
            Text("Create Request")
                .font(.title)
                .bold()

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

            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)

            TextField("Request type", text: $requestType)
                .textFieldStyle(.roundedBorder)

            TextField("Search place", text: $place)
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
            .onTapGesture(coordinateSpace: .global) { location in
                getMapCoordinate(from: location)
            }

            Button("Submit") {
                searchVM.results = []
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
        .onAppear {
            locationManager.manager.startUpdatingLocation()
        }
        .onReceive(locationManager.$userLocation) { location in
            if let location = location {
                region.center = location
                selectedCoordinate = location
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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

    func getMapCoordinate(from location: CGPoint) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight: CGFloat = 150
        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        let cgCoord = mapView.convert(location, toCoordinateFrom: nil)
        self.selectedCoordinate = cgCoord
        self.region.center = cgCoord

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: cgCoord.latitude, longitude: cgCoord.longitude)) { placemarks, _ in
            if let placemark = placemarks?.first {
                self.place = placemark.name ?? "Selected Location"
            }
        }
    }

    func createRequest() {
        guard let user = Auth.auth().currentUser else { return }

        let uid = user.uid
        let usersRef = Database.database().reference().child("users").child(uid)

        usersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard !description.isEmpty, !requestType.isEmpty, !place.isEmpty else {
                    alertMessage = "Please fill in all fields."
                    showAlert = true
                    return
                }

                guard let image = selectedImage,
                      let imageData = image.jpegData(compressionQuality: 0.8) else {
                    alertMessage = "Please select an image."
                    showAlert = true
                    return
                }

                let requestRef = Database.database().reference().child("requests").child(uid).childByAutoId()
                let requestId = requestRef.key ?? UUID().uuidString
                let filename = "\(requestId).jpg"
                let storageRef = Storage.storage().reference().child("request_images").child(filename)

                storageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        alertMessage = "Image upload failed: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }

                    storageRef.downloadURL { url, _ in
                        guard let downloadURL = url else {
                            alertMessage = "Failed to retrieve image URL."
                            showAlert = true
                            return
                        }

                        saveRequest(with: downloadURL.absoluteString, requestId: requestId)
                    }
                }

            } else {
                alertMessage = "You are not a registered user. Please complete your profile."
                showAlert = true
            }
        }
    }

    func saveRequest(with imageUrl: String, requestId: String) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        let requestData: [String: Any] = [
            "description": description,
            "requestType": requestType,
            "place": place,
            "latitude": selectedCoordinate.latitude,
            "longitude": selectedCoordinate.longitude,
            "timestamp": ServerValue.timestamp(),
            "imageUrl": imageUrl,
            "likes": 0,
            "likedBy": [],
            "comments": [],
            "ownerUid": uid,
            "requestId": requestId
        ]

        let requestRef = Database.database().reference().child("requests").child(uid).child(requestId)
        requestRef.setValue(requestData) { error, _ in
            if let error = error {
                alertMessage = "Error saving request: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Your request has been submitted successfully."
                showAlert = true

                // ✅ Clear fields
                description = ""
                requestType = ""
                place = ""
                selectedImage = nil

                // ✅ Dismiss after a short delay so user can see the alert
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }

}

struct MapPinLocation: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}
