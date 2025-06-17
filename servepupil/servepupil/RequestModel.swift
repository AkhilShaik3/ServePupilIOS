import Foundation

struct RequestModel: Identifiable {
    let id: String
    let description: String
    let requestType: String
    let place: String
    let latitude: Double
    let longitude: Double
    let timestamp: Double
    let imageUrl: String?

    init?(id: String, data: [String: Any]) {
        guard
            let description = data["description"] as? String,
            let requestType = data["requestType"] as? String,
            let place = data["place"] as? String,
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double,
            let timestamp = data["timestamp"] as? Double
        else {
            return nil
        }

        self.id = id
        self.description = description
        self.requestType = requestType
        self.place = place
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.imageUrl = data["imageUrl"] as? String
    }
}
