import Foundation

struct RequestModel: Identifiable {
    let id: String
    let ownerUid: String
    let description: String
    let requestType: String
    let place: String
    let latitude: Double
    let longitude: Double
    let timestamp: Double
    let imageUrl: String?
    var likes: Int
    var likedBy: [String]
    var comments: [CommentModel]

    init?(id: String, data: [String: Any], ownerUid: String) {
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
        self.ownerUid = ownerUid
        self.description = description
        self.requestType = requestType
        self.place = place
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.imageUrl = data["imageUrl"] as? String
        self.likes = data["likes"] as? Int ?? 0
        self.likedBy = data["likedBy"] as? [String] ?? []
        self.comments = []
    }
}
