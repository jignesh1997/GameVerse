
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SnakeGamePage extends StatefulWidget {
  @override
  _SnakeGamePageState createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> with TickerProviderStateMixin {
  static const int GRID_SIZE = 20;
  static const double MOVE_DURATION = 0.2; // Duration for each move in seconds
  late double CELL_SIZE;

  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  Offset direction = Offset(1, 0);
  bool isPlaying = false;
  int score = 0;
  late Timer gameTimer;

  late AnimationController moveAnimationController;
  late Animation<double> moveAnimation;
  late AnimationController foodAnimationController;
  late AnimationController gameOverAnimationController;

  @override
  void initState() {
    super.initState();
    moveAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (MOVE_DURATION * 1000).round()),
    );
    moveAnimation = Tween<double>(begin: 0, end: 1).animate(moveAnimationController);
    foodAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    foodAnimationController.repeat(reverse: true);
    gameOverAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    moveAnimationController.dispose();
    foodAnimationController.dispose();
    gameOverAnimationController.dispose();
    if (isPlaying) {
      gameTimer.cancel();
    }
    super.dispose();
  }

  void startGame() {
    setState(() {
      snake = [Offset(5, 5)];
      food = _getRandomPosition();
      direction = Offset(1, 0);
      isPlaying = true;
      score = 0;
    });
    _scheduleNextMove();
  }

  void _scheduleNextMove() {
    moveAnimationController.forward(from: 0).whenComplete(() {
      if (isPlaying) {
        _updateGame();
        _scheduleNextMove();
      }
    });
  }

  void _updateGame() {
    setState(() {
      Offset newHead = Offset(
        (snake.first.dx + direction.dx) % GRID_SIZE,
        (snake.first.dy + direction.dy) % GRID_SIZE,
      );

      if (snake.contains(newHead)) {
        _gameOver();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score++;
        food = _getRandomPosition();
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    setState(() {
      isPlaying = false;
    });
    gameOverAnimationController.forward(from: 0);
  }

  Offset _getRandomPosition() {
    Random random = Random();
    return Offset(random.nextInt(GRID_SIZE).toDouble(), random.nextInt(GRID_SIZE).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.shortestSide * 0.9;
    CELL_SIZE = screenSize / GRID_SIZE;

    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Snake Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              width: screenSize,
              height: screenSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                color: Colors.black12,
              ),
              child: AnimatedBuilder(
                animation: moveAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      ...snake.asMap().entries.map((entry) {
                        int index = entry.key;
                        Offset currentPos = entry.value;
                        Offset previousPos = index == 0 ? currentPos : snake[index - 1];
                        Offset renderPos = Offset(
                          currentPos.dx + (previousPos.dx - currentPos.dx) * moveAnimation.value,
                          currentPos.dy + (previousPos.dy - currentPos.dy) * moveAnimation.value,
                        );
                        return Positioned(
                          left: renderPos.dx * CELL_SIZE,
                          top: renderPos.dy * CELL_SIZE,
                          child: Container(
                            width: CELL_SIZE,
                            height: CELL_SIZE,
                            child: _buildSnakeSegment(index),
                          ),
                        );
                      }),
                      Positioned(
                        left: food.dx * CELL_SIZE,
                        top: food.dy * CELL_SIZE,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.2).animate(foodAnimationController),
                          child: Container(
                            width: CELL_SIZE,
                            height: CELL_SIZE,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDirectionButton(Icons.arrow_upward, Offset(0, -1)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDirectionButton(Icons.arrow_back, Offset(-1, 0)),
                SizedBox(width: 50),
                _buildDirectionButton(Icons.arrow_forward, Offset(1, 0)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDirectionButton(Icons.arrow_downward, Offset(0, 1)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPlaying ? null : startGame,
              child: Text(isPlaying ? 'Playing' : 'Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnakeSegment(int index) {
    if (index == 0) {
      // Head
      return CustomPaint(
        painter: SnakeHeadPainter(direction),
      );
    } else {
      // Body
      return Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(CELL_SIZE / 4),
        ),
      );
    }
  }

  Widget _buildDirectionButton(IconData icon, Offset newDirection) {
    return ElevatedButton(
      onPressed: () {
        if (isPlaying && (direction.dx != -newDirection.dx || direction.dy != -newDirection.dy)) {
          setState(() {
            direction = newDirection;
          });
        }
      },
      child: Icon(icon),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), backgroundColor: Colors.blue,
        padding: EdgeInsets.all(15),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameOverAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    gameOverAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: gameOverAnimationController,
            curve: Curves.easeInOut,
          ),
          child: AlertDialog(
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
          ),
        );
      },
    );
  }
}

class SnakeHeadPainter extends CustomPainter {
  final Offset direction;

  SnakeHeadPainter(this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final tonguePaint = Paint()..color = Colors.red;

    // Draw head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.width / 4),
      ),
      paint,
    );

    // Calculate eye positions based on direction
    double eyeSize = size.width / 5;
    double eyeOffset = size.width / 4;
    
    Offset leftEyePosition;
    Offset rightEyePosition;
    
    if (direction == Offset(1, 0)) { // Right
      leftEyePosition = Offset(size.width - eyeOffset, eyeOffset);
      rightEyePosition = Offset(size.width - eyeOffset, size.height - eyeOffset);
    } else if (direction == Offset(-1, 0)) { // Left
      leftEyePosition = Offset(eyeOffset, size.height - eyeOffset);
      rightEyePosition = Offset(eyeOffset, eyeOffset);
    } else if (direction == Offset(0, 1)) { // Down
      leftEyePosition = Offset(eyeOffset, size.height - eyeOffset);
      rightEyePosition = Offset(size.width - eyeOffset, size.height - eyeOffset);
    } else { // Up
      leftEyePosition = Offset(eyeOffset, eyeOffset);
      rightEyePosition = Offset(size.width - eyeOffset, eyeOffset);
    }

    // Draw eyes
    canvas.drawCircle(leftEyePosition, eyeSize, eyePaint);
    canvas.drawCircle(rightEyePosition, eyeSize, eyePaint);

    // Draw pupils
    canvas.drawCircle(leftEyePosition, eyeSize / 2, pupilPaint);
    canvas.drawCircle(rightEyePosition, eyeSize / 2, pupilPaint);

    // Draw tongue
    Path tonguePath = Path();
    if (direction == Offset(1, 0)) { // Right
      tonguePath.moveTo(size.width, size.height / 2);
      tonguePath.lineTo(size.width + size.width / 4, size.height / 2 - size.height / 8);
      tonguePath.lineTo(size.width + size.width / 4, size.height / 2 + size.height / 8);
      tonguePath.close();
    } else if (direction == Offset(-1, 0)) { // Left
      tonguePath.moveTo(0, size.height / 2);
      tonguePath.lineTo(-size.width / 4, size.height / 2 - size.height / 8);
      tonguePath.lineTo(-size.width / 4, size.height / 2 + size.height / 8);
      tonguePath.close();
    } else if (direction == Offset(0, 1)) { // Down
      tonguePath.moveTo(size.width / 2, size.height);
      tonguePath.lineTo(size.width / 2 - size.width / 8, size.height + size.height / 4);
      tonguePath.lineTo(size.width / 2 + size.width / 8, size.height + size.height / 4);
      tonguePath.close();
    } else { // Up
      tonguePath.moveTo(size.width / 2, 0);
      tonguePath.lineTo(size.width / 2 - size.width / 8, -size.height / 4);
      tonguePath.lineTo(size.width / 2 + size.width / 8, -size.height / 4);
      tonguePath.close();
    }
    canvas.drawPath(tonguePath, tonguePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}