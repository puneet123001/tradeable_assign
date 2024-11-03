import 'package:flutter/material.dart';

void main() {
  runApp(MarbleGameApp());
}

class MarbleGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marble Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 4;
  List<List<int?>> board =
      List.generate(gridSize, (_) => List.filled(gridSize, null));
  bool isPlayerOneTurn = true;
  bool gameWon = false;

  // Place marble on the board
  void placeMarble(int row, int col) {
    if (board[row][col] == null && !gameWon) {
      setState(() {
        // Place the marble for the current player
        board[row][col] = isPlayerOneTurn ? 1 : 2;

        // Check if this move results in a win
        if (checkWinCondition(row, col)) {
          gameWon = true;
          return;
        }

        // Move marbles counterclockwise after each turn
        moveMarblesCounterclockwise();

        // Switch player turn
        isPlayerOneTurn = !isPlayerOneTurn;
      });
    }
  }

  // Check for a winning condition
  bool checkWinCondition(int row, int col) {
    int player = board[row][col]!;
    return checkDirection(player, row, col, 1, 0) || // Horizontal
        checkDirection(player, row, col, 0, 1) || // Vertical
        checkDirection(player, row, col, 1, 1) || // Diagonal \
        checkDirection(player, row, col, 1, -1); // Diagonal /
  }

  // Check four in a row in a specific direction
  bool checkDirection(int player, int row, int col, int dRow, int dCol) {
    int count = 0;
    for (int i = -3; i <= 3; i++) {
      int r = row + i * dRow;
      int c = col + i * dCol;
      if (r >= 0 &&
          r < gridSize &&
          c >= 0 &&
          c < gridSize &&
          board[r][c] == player) {
        count++;
        if (count == 4) return true;
      } else {
        count = 0;
      }
    }
    return false;
  }

  // Move all marbles counterclockwise
  void moveMarblesCounterclockwise() {
    List<List<int?>> newBoard =
        List.generate(gridSize, (_) => List.filled(gridSize, null));

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (board[row][col] != null) {
          final pos = getCounterclockwisePosition(row, col);
          newBoard[pos[0]][pos[1]] = board[row][col];
        }
      }
    }

    board = newBoard;
  }

  // Get the new counterclockwise position
  List<int> getCounterclockwisePosition(int row, int col) {
    if (row == 0 && col > 0) return [0, col - 1]; // Top row, moving left
    if (col == 0 && row < gridSize - 1)
      return [row + 1, 0]; // Left column, moving down
    if (row == gridSize - 1 && col < gridSize - 1)
      return [gridSize - 1, col + 1]; // Bottom row, moving right
    if (col == gridSize - 1 && row > 0)
      return [row - 1, gridSize - 1]; // Right column, moving up

    return [row, col]; // Inner cells don't move
  }

  // Reset the game
  void resetGame() {
    setState(() {
      board = List.generate(gridSize, (_) => List.filled(gridSize, null));
      isPlayerOneTurn = true;
      gameWon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Two-Player Marble Game'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: resetGame),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameWon
                  ? (isPlayerOneTurn ? "Player 1 Wins!" : "Player 2 Wins!")
                  : (isPlayerOneTurn ? "Player 1's Turn" : "Player 2's Turn"),
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                return GestureDetector(
                  onTap: () => placeMarble(row, col),
                  child: Container(
                    margin: EdgeInsets.all(4),
                    color: board[row][col] == 1
                        ? Colors.red
                        : board[row][col] == 2
                            ? Colors.blue
                            : Colors.grey[300],
                    child: Center(
                      child: Text(
                        board[row][col] == null
                            ? ""
                            : (board[row][col] == 1 ? "P1" : "P2"),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
