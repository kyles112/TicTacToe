//
//  GameView.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Waiting for the player")
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    GameButton(title: "Quit", backgroundColor: Color(.systemRed))
                }
                LoadingView()
                
                Spacer()
                
                VStack {
                    LazyVGrid(columns: viewModel.columns, spacing: 5) {
                        ForEach(0..<9) { i in
                            ZStack{
                                GameSquareView(proxy: geometry)
                                PlayerIndicatorView(systemImageName: viewModel.game?.moves[i]?.indicator ?? "applelogo")
                            }
                            .onTapGesture {
                                viewModel.processPlayerMove(for: i)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.getTheGame()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel())
    }
}
