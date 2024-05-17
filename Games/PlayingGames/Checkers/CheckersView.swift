//
//  CheckersView.swift
//  Games
//
//  Created by csuftitan on 5/16/24.
//

import SwiftUI

// MARK: - Model
enum CheckerPiece {
    case none, playerOne, playerTwo, playerOneKing, playerTwoKing
}

struct CheckerSquare {
    var piece: CheckerPiece = .none
    var isHighlighted: Bool = false
}

struct Move {
    var from: (Int, Int)
    var to: (Int, Int)
}

// MARK: - ViewModel
class CheckersViewModel: ObservableObject {
    @Published var board: [[CheckerSquare]] = Array(repeating: Array(repeating: CheckerSquare(), count: 8), count: 8)
    @Published var currentPlayer: CheckerPiece = .playerOne
    @Published var winner: CheckerPiece? = nil
    var possibleMoves: [Move] = []

    init() {
        setupBoard()
    }

    func setupBoard() {
        winner = nil
        currentPlayer = .playerOne
        for i in 0..<8 {
            for j in 0..<8 {
                board[i][j] = CheckerSquare()
                if (i + j) % 2 == 1 {
                    if i < 3 {
                        board[i][j].piece = .playerTwo
                    } else if i > 4 {
                        board[i][j].piece = .playerOne
                    }
                }
            }
        }
    }

    func tapSquare(row: Int, col: Int) {
        if winner != nil {
            return
        }
        
        let selectedSquare = board[row][col]
        if selectedSquare.isHighlighted {
            if let move = possibleMoves.first(where: { $0.to == (row, col) }) {
                executeMove(move)
                switchPlayer()
                performComputerMoveIfNeeded()
            }
        } else {
            clearHighlights()
            if canMovePieceAt(row: row, col: col) {
                calculateMoves(from: (row, col))
                highlightMoves()
            }
        }
    }

    private func canMovePieceAt(row: Int, col: Int) -> Bool {
        let piece = board[row][col].piece
        return (piece == .playerOne && currentPlayer == .playerOne) ||
               (piece == .playerOneKing && currentPlayer == .playerOne) ||
               (piece == .playerTwo && currentPlayer == .playerTwo) ||
               (piece == .playerTwoKing && currentPlayer == .playerTwo)
    }

    private func executeMove(_ move: Move) {
        let piece = board[move.from.0][move.from.1].piece
        board[move.from.0][move.from.1].piece = .none
        board[move.to.0][move.to.1].piece = piece

        // Promote to King
        if (piece == .playerOne && move.to.0 == 0) || (piece == .playerTwo && move.to.0 == 7) {
            board[move.to.0][move.to.1].piece = piece == .playerOne ? .playerOneKing : .playerTwoKing
        }

        // Remove captured piece
        if abs(move.from.0 - move.to.0) == 2 {
            let middleRow = (move.from.0 + move.to.0) / 2
            let middleCol = (move.from.1 + move.to.1) / 2
            board[middleRow][middleCol].piece = .none
        }
        possibleMoves.removeAll()
    }

    private func switchPlayer() {
        currentPlayer = currentPlayer == .playerOne ? .playerTwo : .playerOne
        calculateAllPossibleMoves()
        if possibleMoves.isEmpty {
            winner = currentPlayer == .playerOne ? .playerTwo : .playerOne
        }
    }

    private func performComputerMoveIfNeeded() {
        if currentPlayer == .playerTwo { // Assuming playerTwo is the computer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate thinking delay
                guard let move = self.possibleMoves.randomElement() else {
                    self.switchPlayer() // Switch back if no moves are possible
                    return
                }
                self.executeMove(move)
                self.switchPlayer()
            }
        }
    }

    private func calculateAllPossibleMoves() {
        possibleMoves.removeAll()
        for row in 0..<8 {
            for col in 0..<8 {
                if board[row][col].piece == currentPlayer || board[row][col].piece == (currentPlayer == .playerOne ? .playerOneKing : .playerTwoKing) {
                    calculateMoves(from: (row, col))
                }
            }
        }
    }

    private func calculateMoves(from position: (Int, Int)) {
        let directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        let piece = board[position.0][position.1].piece
        let isKing = piece == .playerOneKing || piece == .playerTwoKing
        for dir in directions {
            let simpleMovePos = (position.0 + dir.0, position.1 + dir.1)
            let jumpMovePos = (position.0 + 2 * dir.0, position.1 + 2 * dir.1)
            if isValidPosition(simpleMovePos) && board[simpleMovePos.0][simpleMovePos.1].piece == .none {
                if isKing || (piece == .playerOne && dir.0 < 0) || (piece == .playerTwo && dir.0 > 0) {
                    possibleMoves.append(Move(from: position, to: simpleMovePos))
                }
            }
            if isValidPosition(jumpMovePos) && board[jumpMovePos.0][jumpMovePos.1].piece == .none {
                let betweenPos = (position.0 + dir.0, position.1 + dir.1)
                if board[betweenPos.0][betweenPos.1].piece != .none && board[betweenPos.0][betweenPos.1].piece != piece {
                    if isKing || (piece == .playerOne && dir.0 < 0) || (piece == .playerTwo && dir.0 > 0) {
                        possibleMoves.append(Move(from: position, to: jumpMovePos))
                    }
                }
            }
        }
    }

    private func isValidPosition(_ position: (Int, Int)) -> Bool {
        return position.0 >= 0 && position.0 < 8 && position.1 >= 0 && position.1 < 8
    }

    private func clearHighlights() {
        for row in 0..<8 {
            for col in 0..<8 {
                board[row][col].isHighlighted = false
            }
        }
    }

    private func highlightMoves() {
        for move in possibleMoves {
            board[move.to.0][move.to.1].isHighlighted = true
        }
    }
}

// MARK: - View
struct CheckersView: View {
    @ObservedObject var viewModel = CheckersViewModel()

    var body: some View {
        VStack {
            Text(viewModel.winner != nil ? "\(playerName(for: viewModel.winner!)) Wins!" : "Current Player: \(playerName(for: viewModel.currentPlayer))")
                .font(.headline)
                .padding()
                .background(viewModel.winner == nil ? (viewModel.currentPlayer == .playerOne ? Color.red.opacity(0.2) : Color.blue.opacity(0.2)) : Color.green.opacity(0.2))
                .foregroundColor(viewModel.winner == nil ? (viewModel.currentPlayer == .playerOne ? Color.red : Color.blue) : Color.green)

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { column in
                            SquareView(square: self.viewModel.board[row][column], row: row, column: column)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    self.viewModel.tapSquare(row: row, col: column)
                                }
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .border(Color.black, width: 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                viewModel.setupBoard()
            }) {
                Text("Restart")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }

    private func playerName(for piece: CheckerPiece) -> String {
        switch piece {
        case .playerOne, .playerOneKing:
            return "Player One"
        case .playerTwo, .playerTwoKing:
            return "Computer"
        default:
            return "Unknown Player"
        }
    }
}

struct SquareView: View {
    var square: CheckerSquare
    var row: Int
    var column: Int

    var body: some View {
        ZStack {
            Rectangle()
                .fill((row + column) % 2 == 0 ? Color.white : Color.black)
            if square.piece != .none {
                Circle()
                    .foregroundColor(color(for: square.piece))
                    .overlay(Circle().stroke(Color.white, lineWidth: square.piece == .playerOneKing || square.piece == .playerTwoKing ? 4 : 0))
            }
            if square.isHighlighted {
                Rectangle()
                    .fill(Color.yellow.opacity(0.4))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func color(for piece: CheckerPiece) -> Color {
        switch piece {
        case .playerOne, .playerOneKing:
            return .red
        case .playerTwo, .playerTwoKing:
            return .blue
        default:
            return .clear
        }
    }
}

// MARK: - Main View
struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CheckersView()) {
                    Image("Guess")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130)
                }
                .navigationBarTitle("Main Menu")
            }
        }
    }
}
// MARK: - Preview
struct CheckersView_Previews: PreviewProvider {
    static var previews: some View {
        CheckersView()
    }
}
