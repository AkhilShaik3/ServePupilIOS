//
//  UserModel.swift
//  servepupil
//
//  Created by Admin on 6/10/25.
//


import Foundation

struct UserModel: Identifiable {
    var id: String // Firebase UID
    var name: String
    var bio: String
    var phone: String
    var imageUrl: String
    var followers: Int
    var following: Int

    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.followers = data["followers"] as? Int ?? 0
        self.following = data["following"] as? Int ?? 0
    }

    func toDict() -> [String: Any] {
        return [
            "name": name,
            "bio": bio,
            "phone": phone,
            "imageUrl": imageUrl,
            "followers": followers,
            "following": following
        ]
    }
}
