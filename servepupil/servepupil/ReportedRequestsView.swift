import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ReportedRequestsView: View {
    @State private var reportedRequests: [RequestModel] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Reported Requests")
                    .font(.title)
                    .bold()

                if reportedRequests.isEmpty {
                    Text("No reported requests.")
                        .foregroundColor(.gray)
                }

                ForEach(reportedRequests) { request in
                    RequestCardView(
                        request: request,
                        showEditDelete: true,
                        onDelete: {
                            if let index = reportedRequests.firstIndex(where: { $0.id == request.id }) {
                                reportedRequests.remove(at: index)
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .onAppear {
            fetchReportedRequests()
        }
    }

    func fetchReportedRequests() {
        let reportRef = Database.database().reference().child("reported_content").child("requests")
        reportRef.observeSingleEvent(of: .value) { snapshot in
            var requestIds: [(id: String, ownerUid: String)] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    let requestId = snap.key
                    requestIds.append((id: requestId, ownerUid: ""))
                }
            }

            fetchFullRequestData(for: requestIds)
        }
    }

    func fetchFullRequestData(for requestIds: [(id: String, ownerUid: String)]) {
        let allRequestsRef = Database.database().reference().child("requests")

        allRequestsRef.observeSingleEvent(of: .value) { snapshot in
            var foundRequests: [RequestModel] = []

            for userSnap in snapshot.children {
                if let userNode = userSnap as? DataSnapshot {
                    let ownerUid = userNode.key

                    for reqSnap in userNode.children {
                        if let requestSnap = reqSnap as? DataSnapshot,
                           let data = requestSnap.value as? [String: Any],
                           requestIds.contains(where: { $0.id == requestSnap.key }) {

                            if let request = RequestModel(id: requestSnap.key, data: data, ownerUid: ownerUid) {
                                foundRequests.append(request)
                            }
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.reportedRequests = foundRequests
            }
        }
    }
}
