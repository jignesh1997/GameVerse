
import 'package:flutter/material.dart';
import 'dart:math';

class SudokuGamePage extends StatefulWidget {
  @override
  _SudokuGamePageState createState() => _SudokuGamePageState();
}

class _SudokuGamePageState extends State<SudokuGamePage> {
  late List<List<int?>> board;
  late List<List<bool>> isOriginal;
  int selectedRow = -1;
  int selectedCol = -1;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    board = List.generate(9, (_) => List.filled(9, null));
    isOriginal = List.generate(9, (_) => List.filled(9, false));
    generatePuzzle();
  }

  void generatePuzzle() {
    // Generate a solved Sudoku board
    solveSudoku(board);

    // Remove some numbers to create the puzzle
    Random random = Random();
    int numbersToRemove = 40 + random.nextInt(15); // Remove 40-54 numbers

    for (int i = 0; i < numbersToRemove; i++) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      if (board[row][col] != null) {
        board[row][col] = null;
      } else {
        i--; // Try again if the cell is already empty
      }
    }

    // Mark original numbers
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        isOriginal[row][col] = board[row][col] != null;
      }
    }
  }

  bool solveSudoku(List<List<int?>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == null) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(board, row, col, num)) {
              board[row][col] = num;
              if (solveSudoku(board)) {
                return true;
              }
              board[row][col] = null;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool isValid(List<List<int?>> board, int row, int col, int num) {
    // Check row
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (board[i][col] == num) return false;
    }

    // Check 3x3 box
    int boxRow = row - row % 3;
    int boxCol = col - col % 3;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (board[i][j] == num) return false;
      }
    }

    return true;
  }

  void selectCell(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void inputNumber(int number) {
    if (selectedRow != -1 && selectedCol != -1 && !isOriginal[selectedRow][selectedCol]) {
      setState(() {
        board[selectedRow][selectedCol] = number;
      });
      if (isBoardFull() && isBoardValid()) {
        showWinDialog();
      }
    }
  }

  bool isBoardFull() {
    for (var row in board) {
      if (row.contains(null)) return false;
    }
    return true;
  }

  bool isBoardValid() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        int? currentNum = board[row][col];
        if (currentNum != null) {
          board[row][col] = null;
          if (!isValid(board, row, col, currentNum)) {
            board[row][col] = currentNum;
            return false;
          }
          board[row][col] = currentNum;
        }
      }
    }
    return true;
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have successfully solved the Sudoku puzzle!'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Sudoku', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      childAspectRatio: 1,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      return GestureDetector(
                        onTap: () => selectCell(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedRow == row && selectedCol == col
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            border: Border(
                              right: BorderSide(
                                width: (col % 3 == 2) ? 2.0 : 1.0,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              bottom: BorderSide(
                                width: (row % 3 == 2) ? 2.0 : 1.0,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              board[row][col]?.toString() ?? '',
                              style: TextStyle(
                                color: isOriginal[row][col] ? Colors.white : Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(9, (index) {
                return ElevatedButton(
                  onPressed: () => inputNumber(index + 1),
                  child: Text('${index + 1}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.all(16),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: startNewGame,
              child: Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}