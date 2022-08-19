//
//  FirebaseService.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Combine

final class FirebaseService: ObservableObject {
    
    static let shared = FirebaseService()
    
    @Published var game: Game!
    
    init(){
        
    }

    func createOnlineGame() {
        // share the game online
        
        do {
            try FirebaseReference(.Game).document(self.game.id).setData(from: self.game )
        } catch {
            print("Error creating online game", error.localizedDescription)
        }
        
    }

    func startGame(with userId: String) {
        
        // check if there is a game to join, if not create a new game, if yes, join and start listening for any changes in the game
     
        FirebaseReference(.Game).whereField("player2Id", isEqualTo: "").whereField("player1Id", isNotEqualTo: userId).getDocuments { querySnapshot, error in
            if error != nil {
                print("Error starting game", error?.localizedDescription)
                // create new game
                self.createNewGame(with: userId)
                return
            }
            
            if let gameData = querySnapshot?.documents.first {
                self.game = try? gameData.data(as: Game.self)
                self.game.player2Id = userId
                self.game.blockMoveForPlayerId = userId
                
                self.updateGame(self.game)
                self.listeningForGameChanges()
            } else {
                self.createNewGame(with: userId)
            }
        }
    }
    
    func listeningForGameChanges() {
        FirebaseReference(.Game).document(self.game.id).addSnapshotListener { documentSnapshot, error in
            print("Change received from Firebase")
            
            if error != nil {
                print("Error listending to changes", error?.localizedDescription)
                return
            }
            if let snapshot = documentSnapshot {
                self.game = try? snapshot.data(as: Game.self)
                
            }
        }
    }
    
    func createNewGame(with userId: String) {
        //create new game object
        print("Creating game for userid", userId)
        
        self.game = Game(id: UUID().uuidString, player1Id: userId, player2Id: "", blockMoveForPlayerId: userId, winningPlayerId: "", rematchPlayerId: [], moves: Array(repeating: nil, count: 9))
        self.createOnlineGame()
        self.listeningForGameChanges()
    }
    
    func updateGame(_ game: Game) {

        do {
            try FirebaseReference(.Game).document(game.id).setData(from: game )
        } catch {
            print("Error updating online game", error.localizedDescription)
        }
        
    }
    
    func quitTheGame() {
        guard game != nil else { return }
        FirebaseReference(.Game).document(self.game.id).delete()
    }
}



