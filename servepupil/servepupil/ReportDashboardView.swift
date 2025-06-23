//
//  ReportDashboardView.swift
//  servepupil
//
//  Created by Admin on 6/19/25.
//


import SwiftUI

struct ReportDashboardView: View {
    var body: some View {
        VStack(spacing: 20) {

            NavigationLink(destination: ReportedRequestsView()) {
                Text("Reported Requests")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            NavigationLink(destination: ReportedUsersView()) {
                Text("Reported Users")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            NavigationLink(destination: ReportedCommentsView()) {
                Text("Reported Comments")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Report Center")
    }
}
