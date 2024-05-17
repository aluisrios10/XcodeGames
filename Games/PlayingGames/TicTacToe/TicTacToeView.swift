//
//  TicTacToeView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

struct TicTacToeView: View {
    @StateObject private var viewModel = TicTacToeViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { column in
                            Button(action: {
                                viewModel.makeMove(row: row, column: column)
                            }) {
                                Text(viewModel.board[row][column])
                                    .font(.system(size: 60))
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                Text(viewModel.isGameOver ? "\(viewModel.winner) wins!" : "")
                    .font(.title)
                    .padding()
                    .foregroundColor(.blue)

                HStack {
                    Button("Play vs Person") {
                        viewModel.startGame(againstAI: false)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Play vs AI") {
                        viewModel.startGame(againstAI: true)
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Button("Restart") {
                    viewModel.restartGame()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if viewModel.isGameOver, let line = viewModel.winningLine {
                WinningLineView(start: line[0], end: line[1])
                    .stroke(Color.red, lineWidth: 8)
                    .frame(width: 300, height: 300)
            }
        }
        .padding()
    }
}

struct WinningLineView: Shape {
    var start: (Int, Int)
    var end: (Int, Int)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepX = rect.width / 3
        let stepY = rect.height / 3
        let startX = CGFloat(start.1) * stepX + stepX / 2
        let startY = CGFloat(start.0) * stepY + stepY / 2
        let endX = CGFloat(end.1) * stepX + stepX / 2
        let endY = CGFloat(end.0) * stepY + stepY / 2
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        return path
    }
}

class TicTacToeViewModel: ObservableObject {
    @Published var board: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    @Published var currentPlayer: String = "X"
    @Published var winner: String = ""
    @Published var isGameOver: Bool = false
    @Published var winningLine: [(Int, Int)]? = nil
    var againstAI = false

    func startGame(againstAI: Bool) {
        self.againstAI = againstAI
        restartGame()
    }

    func makeMove(row: Int, column: Int) {
        if board[row][column] == "" && !isGameOver {
            board[row][column] = currentPlayer
            checkGameStatus(row: row, column: column)
            if !isGameOver && againstAI && currentPlayer == "O" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.botMove()
                }
            }
        }
    }

    func botMove() {
        if !findWinningMove(for: "O") { // First try to win
            if !findWinningMove(for: "X") { // Then try to block
                randomMove()
            }
        }
    }

    func findWinningMove(for player: String) -> Bool {
        for i in 0..<3 {
            for j in 0..<3 {
                if board[i][j] == "" {
                    board[i][j] = player
                    if checkForVictory(of: player, at: i, column: j) {
                        if player == "O" {
                            checkGameStatus(row: i, column: j)
                            return true
                        } else {
                            board[i][j] = "" // Undo if it's a block attempt
                        }
                    } else {
                        board[i][j] = ""
                    }
                }
            }
        }
        return false
    }

    func randomMove() {
        var availableSpaces = [(Int, Int)]()
        for (i, row) in board.enumerated() {
            for (j, value) in row.enumerated() {
                if value == "" {
                    availableSpaces.append((i, j))
                }
            }
        }
        
        if let randomSpace = availableSpaces.randomElement() {
            board[randomSpace.0][randomSpace.1] = currentPlayer
            checkGameStatus(row: randomSpace.0, column: randomSpace.1)
        }
    }

    func checkGameStatus(row: Int, column: Int) {
        if checkForVictory(of: currentPlayer, at: row, column: column) {
            winner = currentPlayer
            isGameOver = true
        } else {
            currentPlayer = currentPlayer == "X" ? "O" : "X"
        }
    }

    func checkForVictory(of player: String, at row: Int, column: Int) -> Bool {
        let wins = [
            [(0, 0), (0, 1), (0, 2)],
            [(1, 0), (1, 1), (1, 2)],
            [(2, 0), (2, 1), (2, 2)],
            [(0, 0), (1, 0), (2, 0)],
            [(0, 1), (1, 1), (2, 1)],
            [(0, 2), (1, 2), (2, 2)],
            [(0, 0), (1, 1), (2, 2)],
            [(0, 2), (1, 1), (2, 0)]
        ]
        for win in wins {
            if win.allSatisfy({ board[$0.0][$0.1] == player }) {
                if isGameOver {
                    winningLine = [(win.first!.0, win.first!.1), (win.last!.0, win.last!.1)]
                }
                return true
            }
        }
        return false
    }

    func restartGame() {
        board = Array(repeating: Array(repeating: "", count: 3), count: 3)
        currentPlayer = "X"
        winner = ""
        isGameOver = false
        winningLine = nil
    }
}


