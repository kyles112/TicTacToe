//
//  PlayerIndicatorView.swift
//  TicTacToe
//
//  Created by user224517 on 8/16/22.
//

import SwiftUI

struct PlayerIndicatorView: View {

    var systemImageName: String
    
    var body: some View {
            Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
            .opacity(systemImageName == "applelogo" ? 0 : 1)
    }
}

struct PlayerIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerIndicatorView(systemImageName: "applelogo")
    }
}
