//
//  GameViewModel.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import SwiftUI
import Combine

final class GameViewModel: ObservableObject {

    @AppStorage("user") private var userData: Data?
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @Published var game: Game?
    @Published var currentUser: User!
    
    private var cancellable: Set<AnyCancellable> = []
    
    private let winPattern: Set<Set<Int>> = [ [0,1,2], [3,4,5], [3,4,5],
                                              [0,3,6], [1,4,7],[2,5,8],
                                              [0,4,8], [2,4,6]
                                              ]
    
    init() {
        retrieveUser()
        if currentUser == nil {
            saveUser()
        }
    }
    
    func getTheGame() {
        FirebaseService.shared.startGame(with: currentUser.id)
        
        FirebaseService.shared.$game
            .assign(to: \.game, on: self)
            .store(in: &cancellable)
    }
    
    func processPlayerMove(for position: Int) {
//    
//        // check if move position is occupied
//        if isSquareOccupied(in: game.moves, forIndex: position) { return }
//        
//        game.moves[position] = Move(isPlayer1: true, boardIndex: position)
//        game.blockMoveForPlayerId = "player2"
//        
//        // block the move for the above use
//        // check for win
//        
//        if checkForWinCondition(for: true, in: game.moves) {
//            print("you have won!")
//        }
//        
//        // check for draw
//        if checkForDraw(in: game.moves) {
//            print("you have drawn")
//        }

    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        
        return moves.contains (where: { $0?.boardIndex == index })
    }
    
    func checkForWinCondition(for player1: Bool, in moves: [Move?] ) -> Bool {
        // remove all nils
        let playerMoves = moves.compactMap { $0 }.filter{ $0.isPlayer1 == player1 }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPattern where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        
        return moves.compactMap { $0 }.count == 9
    }
    
    //Mark: - User object
    
    func saveUser() {
        currentUser = User()
        do {
            let data = try JSONEncoder().encode(currentUser)
            userData = data
        } catch {
            print("couldn't encode user")
        }
    }
    
    func retrieveUser() {
        guard let userData = userData else { return }
        
        do {
            currentUser = try JSONDecoder().decode(User.self, from: userData)
        } catch {
            print("no user saved")
        }
    }
 
}
