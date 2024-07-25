
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryGamePage extends StatefulWidget {
  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> with TickerProviderStateMixin {
  final int numPairs = 8;
  late List<String> icons;
  late List<bool> flipped;
  late List<bool> matched;
  int? firstFlippedIndex;
  bool isProcessing = false;
  int moves = 0;
  int score = 0;
  late Timer timer;
  int secondsElapsed = 0;
  
  late List<AnimationController> flipControllers;
  late List<Animation<double>> flipAnimations;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<String> iconSet = [
      '🍎', '🍌', '🍒', '🍓', '🍊', '🍋', '🍉', '🍇',
      '🍍', '🥝', '🥑', '🥕', '🌽', '🥦', '🍄', '🌶️'
    ];
    iconSet.shuffle();
    icons = [];
    for (int i = 0; i < numPairs; i++) {
      icons.add(iconSet[i]);
      icons.add(iconSet[i]);
    }
    icons.shuffle();
    flipped = List.filled(numPairs * 2, false);
    matched = List.filled(numPairs * 2, false);
    firstFlippedIndex = null;
    moves = 0;
    score = 0;
    secondsElapsed = 0;
    
    flipControllers = List.generate(
      numPairs * 2,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    flipAnimations = flipControllers
        .map((controller) => Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeInOut,
              ),
            ))
        .toList();
    
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void flipTile(int index) {
    if (isProcessing || flipped[index] || matched[index]) return;

    flipControllers[index].forward();

    setState(() {
      flipped[index] = true;
      if (firstFlippedIndex == null) {
        firstFlippedIndex = index;
      } else {
        moves++;
        isProcessing = true;
        if (icons[firstFlippedIndex!] == icons[index]) {
          matched[firstFlippedIndex!] = true;
          matched[index] = true;
          score += 10;
          firstFlippedIndex = null;
          isProcessing = false;
          if (matched.every((m) => m)) {
            endGame();
          }
        } else {
          Future.delayed(Duration(milliseconds: 1000), () {
            flipControllers[firstFlippedIndex!].reverse();
            flipControllers[index].reverse();
            setState(() {
              flipped[firstFlippedIndex!] = false;
              flipped[index] = false;
              firstFlippedIndex = null;
              isProcessing = false;
            });
          });
        }
      }
    });
  }

  void endGame() {
    timer.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You completed the game in $moves moves and $secondsElapsed seconds.\nYour score: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    for (var controller in flipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Memory Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $moves', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('Score: $score', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('Time: ${secondsElapsed}s', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: numPairs * 2,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => flipTile(index),
                    child: AnimatedBuilder(
                      animation: flipAnimations[index],
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.rotationY(flipAnimations[index].value * pi),
                          alignment: Alignment.center,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: matched[index] ? Colors.green : (flipAnimations[index].value > 0.5 ? Colors.white : Colors.blue),
                            child: Center(
                              child: flipAnimations[index].value > 0.5 || matched[index]
                                  ? Transform(
                                      transform: Matrix4.rotationY(pi),
                                      alignment: Alignment.center,
                                      child: Text(
                                        icons[index],
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    )
                                  : Icon(Icons.question_mark, color: Colors.white, size: 32),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  initializeGame();
                });
              },
              child: Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}