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
    
    @Published var game: Game? {
        didSet {
            checkIfGameIsOver()
            
            if game == nil { updateGameNoticationFor(.finished) } else {
                game?.player2Id == "" ? updateGameNoticationFor(.waitingForPlayer) :
                updateGameNoticationFor(.started)
            }
        }
    }
    @Published var gameNotification = GameNotification.waitingForPlayer
    @Published var currentUser: User!
    @Published var alertItem: AlertItem?
    
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
    
        guard game != nil else {return }
        
        // check if move position is occupied
        if isSquareOccupied(in: game!.moves, forIndex: position) { return }
        
        game!.moves[position] = Move(isPlayer1: isPlayerOne(), boardIndex: position)
        game!.blockMoveForPlayerId = currentUser.id
        FirebaseService.shared.updateGame(game!)
        
        // check for win
        if checkForWinCondition(for: isPlayerOne(), in: game!.moves) {
            game!.winningPlayerId = currentUser.id
            FirebaseService.shared.updateGame(game!)
            return
        }
        
        // check for draw
        if checkForDraw(in: game!.moves) {
            game!.winningPlayerId = "0"
            FirebaseService.shared.updateGame(game!)
            return
        }

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
    
    func quitGame() {
        FirebaseService.shared.quitTheGame()
    }
    
    func checkForGameBoardStatus() -> Bool {
        return game != nil ? game!.blockMoveForPlayerId == currentUser.id : false
    }

    func isPlayerOne() -> Bool {
        return game != nil ? game!.player1Id == currentUser.id : false
    }

    func checkIfGameIsOver () {
        alertItem = nil
        
        guard game != nil else {return}
        
        if game!.winningPlayerId == "0" {
            alertItem = AlertContext.draw
        } else if game!.winningPlayerId != "" {
            if game!.winningPlayerId == currentUser.id {
                alertItem = AlertContext.youWin
            } else {
                alertItem = AlertContext.youLost
            }
        }
    }
    
    func resetGame() {
        guard game != nil else {
            alertItem = AlertContext.quit
            return
        }
        
        if game!.rematchPlayerId.count == 1 {
            game!.moves = Array(repeating: nil, count: 9)
            game!.winningPlayerId = ""
            game!.blockMoveForPlayerId = game!.player2Id
        } else if game!.rematchPlayerId.count == 2 {
            game!.rematchPlayerId = []
            
        }
        
        game!.rematchPlayerId.append(currentUser.id)
        
        FirebaseService.shared.updateGame(game!)
    }

    func updateGameNoticationFor(_ state: GameState) {
        
        switch state {
        case .started:
            gameNotification = GameNotification.gameHasStarted
        case .waitingForPlayer:
            gameNotification = GameNotification.waitingForPlayer
        case .finished:
            gameNotification = GameNotification.gameFinished
        }
    }
    
    //Mark: - User object
    
    func saveUser() {
        currentUser = User()
        do {
            let data = try JSONEncoder().encode(currentUser)
            userData = data
        } catch {
            print("Error, couldn't encode user")
        }
    }
    
    func retrieveUser() {
        guard let userData = userData else { return }
        
        do {
            currentUser = try JSONDecoder().decode(User.self, from: userData)
        } catch {
            print("Error, no user saved")
        }
    }
 
}
