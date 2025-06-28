//
//  AllUserRequestsView.swift
//  servepupil
//
//  Created by Admin on 6/22/25.
//


import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct AllUserRequestsView: View {
    @State private var allRequests: [RequestModel] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("All User Requests")
                    .font(.title)
                    .bold()

                if allRequests.isEmpty {
                    Text("No requests found.")
                        .foregroundColor(.gray)
                }

                ForEach(allRequests) { request in
                    RequestCardView(
                        request: request,
                        showEditDelete: true,
                        onDelete: {
                            if let index = allRequests.firstIndex(where: { $0.id == request.id }) {
                                allRequests.remove(at: index)
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .onAppear {
            startListeningForAllRequests()
        }
    }

    func startListeningForAllRequests() {
        let allRequestsRef = Database.database().reference().child("requests")

        // ✅ Live listener
        allRequestsRef.observe(.value) { snapshot in
            var foundRequests: [RequestModel] = []

            for userSnap in snapshot.children {
                if let userNode = userSnap as? DataSnapshot {
                    let ownerUid = userNode.key

                    for reqSnap in userNode.children {
                        if let requestSnap = reqSnap as? DataSnapshot,
                           let data = requestSnap.value as? [String: Any],
                           let request = RequestModel(id: requestSnap.key, data: data, ownerUid: ownerUid) {
                            foundRequests.append(request)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.allRequests = foundRequests
            }
        }
    }
}
