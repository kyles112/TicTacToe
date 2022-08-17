//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import SwiftUI
import Firebase

@main
struct TicTacToeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
