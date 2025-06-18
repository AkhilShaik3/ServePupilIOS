//
//  CommentModel.swift
//  servepupil
//
//  Created by Admin on 6/16/25.
//


import Foundation

struct CommentModel: Identifiable {
    let id: String
    let uid: String
    let text: String
    let timestamp: Double

    init?(id: String, data: [String: Any]) {
        guard
            let uid = data["uid"] as? String,
            let text = data["text"] as? String,
            let timestamp = data["timestamp"] as? Double
        else {
            return nil
        }

        self.id = id
        self.uid = uid
        self.text = text
        self.timestamp = timestamp
    }
}
