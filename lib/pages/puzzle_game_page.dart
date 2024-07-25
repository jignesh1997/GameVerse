
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

class PuzzleGamePage extends StatefulWidget {
  @override
  _PuzzleGamePageState createState() => _PuzzleGamePageState();
}

class _PuzzleGamePageState extends State<PuzzleGamePage> {
  final int gridSize = 3;
  late List<int> tiles;
  int moves = 0;
  late Stopwatch stopwatch;
  late Timer timer;
  bool showSolution = false;

  final List<Color> tileColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    tiles.shuffle();
    while (!isSolvable(tiles)) {
      tiles.shuffle();
    }
    moves = 0;
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  bool isSolvable(List<int> tiles) {
    int inversionCount = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] != gridSize * gridSize - 1 &&
            tiles[j] != gridSize * gridSize - 1 &&
            tiles[i] > tiles[j]) {
          inversionCount++;
        }
      }
    }
    return inversionCount % 2 == 0;
  }

  void moveTile(int index) {
    if (index - 1 >= 0 && tiles[index - 1] == gridSize * gridSize - 1 && index % gridSize != 0) {
      setState(() {
        tiles[index - 1] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        moves++;
      });
    } else if (index + 1 < gridSize * gridSize &&
        tiles[index + 1] == gridSize * gridSize - 1 &&
        (index + 1) % gridSize != 0) {
      setState(() {
        tiles[index + 1] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        moves++;
      });
    } else if (index - gridSize >= 0 && tiles[index - gridSize] == gridSize * gridSize - 1) {
      setState(() {
        tiles[index - gridSize] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        moves++;
      });
    } else if (index + gridSize < gridSize * gridSize &&
        tiles[index + gridSize] == gridSize * gridSize - 1) {
      setState(() {
        tiles[index + gridSize] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        moves++;
      });
    }

    if (isGameComplete()) {
      stopwatch.stop();
      timer.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You solved the puzzle in $moves moves and ${stopwatch.elapsed.inSeconds} seconds!'),
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
  }

  bool isGameComplete() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    stopwatch.stop();
    timer.cancel();
    super.dispose();
  }

  Widget buildTile(int index) {
    if (tiles[index] == gridSize * gridSize - 1) {
      return SizedBox();
    }
    return GestureDetector(
      onTap: () => moveTile(index),
      child: Container(
        decoration: BoxDecoration(
          color: tileColors[tiles[index] % tileColors.length],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${tiles[index] + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Puzzle Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $moves', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Time: ${stopwatch.elapsed.inSeconds}s', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  childAspectRatio: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) => buildTile(index),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startNewGame,
                  child: Text('New Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSolution = !showSolution;
                    });
                  },
                  child: Text(showSolution ? 'Hide Solution' : 'Show Solution'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          if (showSolution)
            Container(
              width: 150,
              height: 150,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  if (index == gridSize * gridSize - 1) {
                    return Container(color: Colors.grey[300]);
                  }
                  return Container(
                    color: tileColors[index % tileColors.length],
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}