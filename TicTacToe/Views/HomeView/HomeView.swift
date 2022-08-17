//
//  HomeView.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import SwiftUI

struct HomeView: View {
    
@StateObject var viewModel = HomeViewModel()

    var body: some View {
        VStack {
            Button {
                viewModel.isGameViewPresented = true
            } label: {
                GameButton(title: "Play", backgroundColor: Color(.systemGreen))
            }
        }
        .fullScreenCover(isPresented: $viewModel.isGameViewPresented) {
            GameView(viewModel: GameViewModel())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
