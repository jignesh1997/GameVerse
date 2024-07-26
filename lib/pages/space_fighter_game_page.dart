
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SpaceFighterGamePage extends StatefulWidget {
  @override
  _SpaceFighterGamePageState createState() => _SpaceFighterGamePageState();
}

class _SpaceFighterGamePageState extends State<SpaceFighterGamePage> {
  static const int NUM_ENEMIES = 5;
  static const double PLAYER_SIZE = 50;
  static const double ENEMY_SIZE = 40;
  static const double LASER_HEIGHT = 20;
  static const double LASER_WIDTH = 5;
  static const double PLAYER_WIDTH = 40;
  static const double PLAYER_HEIGHT = 60;


  late double screenWidth;
  late double screenHeight;
  double playerX = 0;
  double playerVelocity = 0;
  List<double> enemyX = List.filled(NUM_ENEMIES, 0);
  List<double> enemyY = List.filled(NUM_ENEMIES, 0);
  List<Laser> lasers = [];
  int score = 0;
  bool isGameOver = false;
  Timer? gameTimer;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      startGame();
      startAccelerometerListening();
    });
  }

  void startAccelerometerListening() {
    accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // Use the x-axis acceleration to set player velocity
        playerVelocity = -event.x * 2; // Adjust this multiplier to change sensitivity
      });
    });
  }

  void startGame() {
    resetGame();
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) { // ~60 FPS
      updateGame();
    });
  }

  void resetGame() {
    playerX = screenWidth / 2 - PLAYER_SIZE / 2;
    playerVelocity = 0;
    for (int i = 0; i < NUM_ENEMIES; i++) {
      enemyX[i] = Random().nextDouble() * (screenWidth - ENEMY_SIZE);
      enemyY[i] = Random().nextDouble() * screenHeight / 2;
    }
    lasers.clear();
    score = 0;
    isGameOver = false;
  }

  void updateGame() {
    if (isGameOver) return;

    setState(() {
      // Update player position based on velocity
      playerX += playerVelocity;
      playerX = playerX.clamp(0, screenWidth - PLAYER_SIZE);

      // Move enemies
      for (int i = 0; i < NUM_ENEMIES; i++) {
        enemyY[i] += 2;
        if (enemyY[i] > screenHeight) {
          enemyX[i] = Random().nextDouble() * (screenWidth - ENEMY_SIZE);
          enemyY[i] = 0;
        }
      }

      // Move and remove lasers
      lasers.removeWhere((laser) {
        laser.move();
        return laser.isOffScreen();
      });

      // Check for collisions
      for (int i = 0; i < NUM_ENEMIES; i++) {
        for (int j = lasers.length - 1; j >= 0; j--) {
          if (lasers[j].x >= enemyX[i] &&
              lasers[j].x <= enemyX[i] + ENEMY_SIZE &&
              lasers[j].y <= enemyY[i] + ENEMY_SIZE &&
              lasers[j].y >= enemyY[i]) {
            score++;
            enemyX[i] = Random().nextDouble() * (screenWidth - ENEMY_SIZE);
            enemyY[i] = 0;
            lasers.removeAt(j);
            break;
          }
        }

        // Check for player collision
        if (enemyY[i] + ENEMY_SIZE >= screenHeight - PLAYER_SIZE &&
            enemyX[i] + ENEMY_SIZE >= playerX &&
            enemyX[i] <= playerX + PLAYER_SIZE) {
          gameOver();
        }
      }
    });
  }

  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
    accelerometerSubscription?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
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
                startAccelerometerListening();
              },
            ),
          ],
        );
      },
    );
  }

  void shoot() {
    setState(() {
      lasers.add(Laser(playerX + PLAYER_SIZE / 2 - LASER_WIDTH / 2, screenHeight - PLAYER_SIZE - LASER_HEIGHT));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game area
          GestureDetector(
            onTap: shoot,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          // Stars
          ...List.generate(50, (index) {
            return Positioned(
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                color: Colors.white,
              ),
            );
          }),
          // Player (Rocket)
          Positioned(
            left: playerX,
            bottom: 20,
            child: CustomPaint(
              size: Size(PLAYER_WIDTH, PLAYER_HEIGHT),
              painter: RocketPainter(),
            ),
          ),
          // Enemies
          ...List.generate(NUM_ENEMIES, (index) {
            return Positioned(
              left: enemyX[index],
              top: enemyY[index],
              child: Container(
                width: ENEMY_SIZE,
                height: ENEMY_SIZE,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
          // Lasers
          ...lasers.map((laser) {
            return Positioned(
              left: laser.x,
              top: laser.y,
              child: Container(
                width: LASER_WIDTH,
                height: LASER_HEIGHT,
                color: Colors.red,
              ),
            );
          }),
          // Score
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Score: $score',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // Fire button
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: shoot,
              child: Text('Fire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    accelerometerSubscription?.cancel();
    super.dispose();
  }
}
class RocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();

    // Rocket body
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.lineTo(0, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);

    // Rocket window
    final windowPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.3),
      size.width * 0.15,
      windowPaint,
    );

    // Rocket fins
    final finPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final leftFin = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();

    final rightFin = Path()
      ..moveTo(size.width, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..close();

    canvas.drawPath(leftFin, finPaint);
    canvas.drawPath(rightFin, finPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
class Laser {
  double x;
  double y;
  static const double speed = 10;

  Laser(this.x, this.y);

  void move() {
    y -= speed;
  }

  bool isOffScreen() {
    return y < 0;
  }
}