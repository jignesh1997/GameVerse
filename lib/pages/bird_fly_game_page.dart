
import 'package:flutter/material.dart';
import 'dart:async';

class BirdFlyGamePage extends StatefulWidget {
  @override
  _BirdFlyGamePageState createState() => _BirdFlyGamePageState();
}

class _BirdFlyGamePageState extends State<BirdFlyGamePage> {
  static const double birdSize = 60.0;
  static const double pipeWidth = 100.0;
  static const double pipeGap = 200.0;

  double birdY = 0;
  double pipeX = 400;
  double pipeTopHeight = 200;
  int score = 0;
  bool isPlaying = false;
  late Timer gameTimer;

  void startGame() {
    if (isPlaying) return;
    isPlaying = true;
    birdY = 0;
    pipeX = 400;
    score = 0;
    gameTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    setState(() {
      birdY += 5; // Bird falls
      pipeX -= 5; // Pipe moves left

      if (pipeX < -pipeWidth) {
        pipeX = MediaQuery.of(context).size.width;
        pipeTopHeight = 100 + (300 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
        score++;
      }

      if (checkCollision()) {
        gameOver();
      }
    });
  }

  bool checkCollision() {
    if (birdY < 0 || birdY > MediaQuery.of(context).size.height - birdSize) {
      return true;
    }

    if (pipeX < birdSize && pipeX + pipeWidth > 0) {
      if (birdY < pipeTopHeight || birdY + birdSize > pipeTopHeight + pipeGap) {
        return true;
      }
    }

    return false;
  }

  void gameOver() {
    isPlaying = false;
    gameTimer.cancel();
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
              },
            ),
          ],
        );
      },
    );
  }

  void jump() {
    if (!isPlaying) {
      startGame();
    } else {
      setState(() {
        birdY -= 50; // Bird jumps up
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Bird Fly', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: jump,
        child: Stack(
          children: [
            // Bird
            Positioned(
              left: 50,
              top: birdY,
              child: Container(
                width: birdSize,
                height: birdSize,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Pipe Top
            Positioned(
              left: pipeX,
              top: 0,
              child: Container(
                width: pipeWidth,
                height: pipeTopHeight,
                color: Colors.green,
              ),
            ),
            // Pipe Bottom
            Positioned(
              left: pipeX,
              bottom: 0,
              child: Container(
                width: pipeWidth,
                height: MediaQuery.of(context).size.height - pipeTopHeight - pipeGap,
                color: Colors.green,
              ),
            ),
            // Score
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Score: $score',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Start message
            if (!isPlaying)
              Center(
                child: Text(
                  'Tap to Start',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}