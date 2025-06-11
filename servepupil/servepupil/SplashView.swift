//
//  SplashView.swift
//  servepupil
//
//  Created by Admin on 6/9/25.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    Image("servepupillogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("ServePupil")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                }

                NavigationLink(destination: SignupView(), isActive: $isActive) {
                    EmptyView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isActive = true
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
