//
//  servepupilApp.swift
//  servepupil
//
//  Created by Admin on 6/7/25.
//

import SwiftUI
import Firebase

@main
struct servepupilApp: App {
    
    init() {
           FirebaseApp.configure()
       }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
