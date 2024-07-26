
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TetrisGamePage extends StatefulWidget {
  @override
  _TetrisGamePageState createState() => _TetrisGamePageState();
}

class _TetrisGamePageState extends State<TetrisGamePage> {
  static const int ROWS = 20;
  static const int COLS = 10;
  static const Duration GAME_TICK = Duration(milliseconds: 800); // Slowed down the game speed

  late List<List<Color?>> board;
  late Timer gameTimer;
  late Tetromino currentPiece;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    board = List.generate(ROWS, (_) => List.filled(COLS, null));
    currentPiece = Tetromino.getRandom();
    score = 0;
    isGameOver = false;
    gameTimer = Timer.periodic(GAME_TICK, (timer) {
      if (!isGameOver) {
        setState(() {
          if (canMoveDown()) {
            currentPiece.moveDown();
          } else {
            placePiece();
            clearLines();
            currentPiece = Tetromino.getRandom();
            if (!canMoveDown()) {
              gameOver();
            }
          }
        });
      }
    });
  }

  bool canMoveDown() {
    for (var point in currentPiece.points) {
      int newRow = point.dy.toInt() + currentPiece.position.dy.toInt() + 1;
      int col = point.dx.toInt() + currentPiece.position.dx.toInt();
      if (newRow >= ROWS || board[newRow][col] != null) {
        return false;
      }
    }
    return true;
  }

  bool canMove(Offset direction) {
    for (var point in currentPiece.points) {
      int newRow = point.dy.toInt() + currentPiece.position.dy.toInt() + direction.dy.toInt();
      int newCol = point.dx.toInt() + currentPiece.position.dx.toInt() + direction.dx.toInt();
      if (newRow < 0 || newRow >= ROWS || newCol < 0 || newCol >= COLS || board[newRow][newCol] != null) {
        return false;
      }
    }
    return true;
  }

  void placePiece() {
    for (var point in currentPiece.points) {
      int row = point.dy.toInt() + currentPiece.position.dy.toInt();
      int col = point.dx.toInt() + currentPiece.position.dx.toInt();
      if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        board[row][col] = currentPiece.color;
      }
    }
  }

  void clearLines() {
    for (int row = ROWS - 1; row >= 0; row--) {
      for (int col = 0; col <= COLS - 5; col++) {
        if (board[row][col] != null &&
            board[row][col] == board[row][col + 1] &&
            board[row][col] == board[row][col + 2] &&
            board[row][col] == board[row][col + 3] &&
            board[row][col] == board[row][col + 4]) {
          // Clear 5 consecutive blocks of the same color
          for (int i = 0; i < 5; i++) {
            board[row][col + i] = null;
          }
          score += 50; // Increase score for clearing blocks

          // Move blocks above down
          for (int r = row - 1; r >= 0; r--) {
            for (int c = col; c < col + 5; c++) {
              if (board[r][c] != null) {
                board[r + 1][c] = board[r][c];
                board[r][c] = null;
              }
            }
          }
        }
      }
    }
  }

  void gameOver() {
    isGameOver = true;
    gameTimer.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  void moveLeft() {
    if (canMove(Offset(-1, 0))) {
      setState(() {
        currentPiece.moveLeft();
      });
    }
  }

  void moveRight() {
    if (canMove(Offset(1, 0))) {
      setState(() {
        currentPiece.moveRight();
      });
    }
  }

  void rotate() {
    setState(() {
      currentPiece.rotate();
      if (!canMove(Offset(0, 0))) {
        currentPiece.rotateBack();
      }
    });
  }

  void dropPiece() {
    while (canMoveDown()) {
      currentPiece.moveDown();
    }
    placePiece();
    clearLines();
    currentPiece = Tetromino.getRandom();
    if (!canMoveDown()) {
      gameOver();
    }
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tetris', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Text('Score: $score', style: TextStyle(color: Colors.white, fontSize: 20)),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  moveLeft();
                } else if (details.primaryVelocity! > 0) {
                  moveRight();
                }
              },
              onTap: rotate,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  dropPiece();
                }
              },
              child: AspectRatio(
                aspectRatio: COLS / ROWS,
                child: CustomPaint(
                  painter: TetrisPainter(board: board, currentPiece: currentPiece),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: moveLeft,
                  child: Icon(Icons.arrow_left),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: rotate,
                  child: Icon(Icons.rotate_right),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: moveRight,
                  child: Icon(Icons.arrow_right),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: dropPiece,
                  child: Icon(Icons.arrow_downward),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TetrisPainter extends CustomPainter {
  final List<List<Color?>> board;
  final Tetromino currentPiece;

  TetrisPainter({required this.board, required this.currentPiece});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / _TetrisGamePageState.COLS;
    final cellHeight = size.height / _TetrisGamePageState.ROWS;

    for (int row = 0; row < _TetrisGamePageState.ROWS; row++) {
      for (int col = 0; col < _TetrisGamePageState.COLS; col++) {
        if (board[row][col] != null) {
          drawCell(canvas, row, col, board[row][col]!, cellWidth, cellHeight);
        }
      }
    }

    for (var point in currentPiece.points) {
      int row = point.dy.toInt() + currentPiece.position.dy.toInt();
      int col = point.dx.toInt() + currentPiece.position.dx.toInt();
      drawCell(canvas, row, col, currentPiece.color, cellWidth, cellHeight);
    }
  }

  void drawCell(Canvas canvas, int row, int col, Color color, double cellWidth, double cellHeight) {
    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(
      Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Tetromino {
  List<Offset> points;
  Offset position;
  Color color;

  Tetromino({required this.points, required this.color}) : position = Offset(5, 0);

  void moveDown() {
    position = Offset(position.dx, position.dy + 1);
  }

  void moveLeft() {
    position = Offset(position.dx - 1, position.dy);
  }

  void moveRight() {
    position = Offset(position.dx + 1, position.dy);
  }

  void rotate() {
    for (int i = 0; i < points.length; i++) {
      double x = points[i].dx;
      double y = points[i].dy;
      points[i] = Offset(y, -x);
    }
  }

  void rotateBack() {
    for (int i = 0; i < points.length; i++) {
      double x = points[i].dx;
      double y = points[i].dy;
      points[i] = Offset(-y, x);
    }
  }

  static Tetromino getRandom() {
    switch (Random().nextInt(7)) {
      case 0:
        return Tetromino(
          points: [Offset(0, 0), Offset(1, 0), Offset(0, 1), Offset(1, 1)],
          color: Colors.yellow,
        );
      case 1:
        return Tetromino(
          points: [Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(0, 3)],
          color: Colors.cyan,
        );
      case 2:
        return Tetromino(
          points: [Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(1, 2)],
          color: Colors.orange,
        );
      case 3:
        return Tetromino(
          points: [Offset(1, 0), Offset(1, 1), Offset(1, 2), Offset(0, 2)],
          color: Colors.blue,
        );
      case 4:
        return Tetromino(
          points: [Offset(0, 0), Offset(0, 1), Offset(1, 1), Offset(1, 2)],
          color: Colors.green,
        );
      case 5:
        return Tetromino(
          points: [Offset(1, 0), Offset(1, 1), Offset(0, 1), Offset(0, 2)],
          color: Colors.red,
        );
      default:
        return Tetromino(
          points: [Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(1, 1)],
          color: Colors.purple,
        );
    }
  }
}