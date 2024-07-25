
import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToePage extends StatefulWidget {
  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> with TickerProviderStateMixin {
  late List<List<String>> board;
  late bool xTurn;
  late String winner;
  late List<List<AnimationController>> animationControllers;
  late AnimationController winLineAnimationController;
  late Animation<double> winLineAnimation;
  List<int>? winningLine;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    xTurn = true;
    winner = '';
    winningLine = null;
    animationControllers = List.generate(
      3,
      (_) => List.generate(
        3,
        (_) => AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        ),
      ),
    );
    winLineAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    winLineAnimation = Tween<double>(begin: 0, end: 1).animate(winLineAnimationController);
  }

  @override
  void dispose() {
    for (var row in animationControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    winLineAnimationController.dispose();
    super.dispose();
  }

  void _makeMove(int row, int col) {
    if (board[row][col] == '' && winner == '') {
      setState(() {
        board[row][col] = xTurn ? 'X' : 'O';
        xTurn = !xTurn;
        animationControllers[row][col].forward();
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
        _setWinner(board[i][0], [i, 0, i, 1, i, 2]);
        return;
      }
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != '' && board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
        _setWinner(board[0][i], [0, i, 1, i, 2, i]);
        return;
      }
    }
    // Check diagonals
    if (board[0][0] != '' && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
      _setWinner(board[0][0], [0, 0, 1, 1, 2, 2]);
      return;
    }
    if (board[0][2] != '' && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
      _setWinner(board[0][2], [0, 2, 1, 1, 2, 0]);
      return;
    }
    // Check for draw
    if (!board.any((row) => row.any((cell) => cell == ''))) {
      setState(() {
        winner = 'Draw';
      });
    }
  }

  void _setWinner(String player, List<int> line) {
    setState(() {
      winner = player;
      winningLine = line;
      winLineAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tic Tac Toe', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            winner == '' ? (xTurn ? 'X\'s Turn' : 'O\'s Turn') : (winner == 'Draw' ? 'It\'s a Draw!' : 'Winner: $winner'),
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Stack(
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      int row = index ~/ 3;
                      int col = index % 3;
                      return GestureDetector(
                        onTap: () => _makeMove(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: ScaleTransition(
                              scale: animationControllers[row][col],
                              child: Text(
                                board[row][col],
                                style: TextStyle(fontSize: 40, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (winningLine != null)
                    AnimatedBuilder(
                      animation: winLineAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: WinLinePainter(
                            winningLine!,
                            winLineAnimation.value,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
            child: Text('Restart Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class WinLinePainter extends CustomPainter {
  final List<int> line;
  final double progress;

  WinLinePainter(this.line, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    final startX = (line[1] + 0.5) * cellWidth;
    final startY = (line[0] + 0.5) * cellHeight;
    final endX = (line[5] + 0.5) * cellWidth;
    final endY = (line[4] + 0.5) * cellHeight;

    canvas.drawLine(
      Offset(startX, startY),
      Offset(startX + (endX - startX) * progress, startY + (endY - startY) * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}