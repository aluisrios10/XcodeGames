//
//  ConnectFourView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

enum Player: String {
    case red = "Player 1 (Red)"
    case yellow = "Player 2 (Yellow)"
}

struct ConnectFourView: View {
    @State private var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 7), count: 6)
    @State private var currentPlayer: Player = .red
    @State private var winner: Player? = nil
    @State private var isAIEnabled: Bool = true
    
    var body: some View {
        VStack {
            Text("Current Player: \(currentPlayer.rawValue)")
                .padding()
            
            VStack(spacing: 5) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<7, id: \.self) { col in
                            Circle()
                                .foregroundColor(getCircleColor(for: board[row][col]))
                                .frame(width: 50, height: 50)
                                .background(Color.gray)
                                .onTapGesture {
                                    if board[row][col] == nil && winner == nil {
                                        placePiece(col: col)
                                    }
                                }
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue)
            
            if let winner = winner {
                Text("Winner: \(winner.rawValue)")
                    .padding()
            } else if checkForDraw() {
                Text("It's a draw!")
                    .padding()
            }
            
            Toggle(isOn: $isAIEnabled) {
                Text("Play against AI")
            }
            .padding()
            
            Button(action: restartGame) {
                Text("Restart")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func getCircleColor(for player: Player?) -> Color {
        switch player {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .none:
            return .white
        }
    }
    
    private func placePiece(col: Int) {
        for row in stride(from: 5, through: 0, by: -1) {
            if board[row][col] == nil {
                board[row][col] = currentPlayer
                if checkForWin(row: row, col: col) {
                    winner = currentPlayer
                } else {
                    currentPlayer = (currentPlayer == .red) ? .yellow : .red
                    if currentPlayer == .yellow && isAIEnabled {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            aiMove()
                        }
                    }
                }
                break
            }
        }
    }
    
    private func aiMove() {
        var availableCols: [Int] = []
        for col in 0..<7 {
            if board[0][col] == nil {
                availableCols.append(col)
            }
        }
        if let aiCol = availableCols.randomElement() {
            placePiece(col: aiCol)
        }
    }
    
    private func checkForWin(row: Int, col: Int) -> Bool {
        return checkDirection(row: row, col: col, rowDir: 0, colDir: 1) // Horizontal
            || checkDirection(row: row, col: col, rowDir: 1, colDir: 0) // Vertical
            || checkDirection(row: row, col: col, rowDir: 1, colDir: 1) // Diagonal (\)
            || checkDirection(row: row, col: col, rowDir: 1, colDir: -1) // Diagonal (/)
    }
    
    private func checkDirection(row: Int, col: Int, rowDir: Int, colDir: Int) -> Bool {
        let player = board[row][col]
        var count = 0
        
        for i in -3...3 {
            let newRow = row + i * rowDir
            let newCol = col + i * colDir
            
            if newRow >= 0 && newRow < 6 && newCol >= 0 && newCol < 7 && board[newRow][newCol] == player {
                count += 1
                if count == 4 {
                    return true
                }
            } else {
                count = 0
            }
        }
        
        return false
    }
    
    private func checkForDraw() -> Bool {
        for row in 0..<6 {
            for col in 0..<7 {
                if board[row][col] == nil {
                    return false
                }
            }
        }
        return true
    }
    
    private func restartGame() {
        board = Array(repeating: Array(repeating: nil, count: 7), count: 6)
        currentPlayer = .red
        winner = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectFourView()
    }
}
