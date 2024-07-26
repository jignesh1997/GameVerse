
import 'package:flutter/material.dart';
import 'dart:math';

class WordSearchGamePage extends StatefulWidget {
  @override
  _WordSearchGamePageState createState() => _WordSearchGamePageState();
}

class _WordSearchGamePageState extends State<WordSearchGamePage> {
  final int gridSize = 10;
  final int wordCount = 8;
  late List<List<String>> grid;
  late List<String> words;
  List<String> foundWords = [];
  List<List<int>> selectedCells = [];

  // Diverse pool of common words
  final List<String> wordPool = [
    "DOG", "CAT", "BIRD", "FISH", "TREE", "FLOWER", "SUN", "MOON", "STAR", "CLOUD",
    "RAIN", "SNOW", "WIND", "RIVER", "OCEAN", "MOUNTAIN", "FOREST", "BEACH", "ISLAND",
    "BOOK", "PEN", "PENCIL", "PAPER", "SCHOOL", "TEACHER", "STUDENT", "FRIEND", "FAMILY",
    "HOUSE", "DOOR", "WINDOW", "ROOF", "FLOOR", "WALL", "CHAIR", "TABLE", "BED", "LAMP",
    "CLOCK", "PHONE", "COMPUTER", "MUSIC", "MOVIE", "GAME", "SPORT", "BALL", "TEAM",
    "FOOD", "WATER", "JUICE", "MILK", "BREAD", "CHEESE", "FRUIT", "VEGETABLE", "MEAT",
    "CAKE", "COOKIE", "CANDY", "CHOCOLATE", "ICE CREAM", "PIZZA", "HAMBURGER", "SALAD",
    "CAR", "BIKE", "BOAT", "TRAIN", "PLANE", "BUS", "ROAD", "STREET", "BRIDGE", "PARK",
    "GARDEN", "FARM", "ZOO", "MUSEUM", "LIBRARY", "STORE", "MARKET", "RESTAURANT", "CAFE",
    "DOCTOR", "NURSE", "POLICE", "FIREFIGHTER", "CHEF", "ARTIST", "MUSICIAN", "ACTOR",
    "COLOR", "RED", "BLUE", "GREEN", "YELLOW", "PURPLE", "ORANGE", "PINK", "BROWN", "BLACK",
    "HEART", "SMILE", "LAUGH", "CRY", "SLEEP", "DREAM", "LOVE", "HAPPY", "SAD", "ANGRY"
  ];

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    words = getRandomWords();
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    foundWords.clear();
    selectedCells.clear();
    placeWords();
    fillEmptyCells();
  }

  List<String> getRandomWords() {
    final random = Random();
    final shuffledWords = List<String>.from(wordPool)..shuffle(random);
    return shuffledWords.take(wordCount).toList();
  }

  void placeWords() {
    Random random = Random();
    for (String word in words) {
      bool placed = false;
      while (!placed) {
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);
        int direction = random.nextInt(3); // 0: horizontal, 1: vertical, 2: diagonal

        if (canPlaceWord(word, row, col, direction)) {
          placeWord(word, row, col, direction);
          placed = true;
        }
      }
    }
  }

  bool canPlaceWord(String word, int row, int col, int direction) {
    if (direction == 0 && col + word.length > gridSize) return false;
    if (direction == 1 && row + word.length > gridSize) return false;
    if (direction == 2 && (row + word.length > gridSize || col + word.length > gridSize)) return false;

    for (int i = 0; i < word.length; i++) {
      int r = direction == 1 ? row + i : (direction == 2 ? row + i : row);
      int c = direction == 0 ? col + i : (direction == 2 ? col + i : col);
      if (grid[r][c] != '' && grid[r][c] != word[i]) return false;
    }
    return true;
  }

  void placeWord(String word, int row, int col, int direction) {
    for (int i = 0; i < word.length; i++) {
      int r = direction == 1 ? row + i : (direction == 2 ? row + i : row);
      int c = direction == 0 ? col + i : (direction == 2 ? col + i : col);
      grid[r][c] = word[i];
    }
  }

  void fillEmptyCells() {
    Random random = Random();
    const String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == '') {
          grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void onCellSelected(int row, int col) {
    setState(() {
      if (selectedCells.isEmpty || areAdjacent(selectedCells.last, [row, col])) {
        selectedCells.add([row, col]);
      } else {
        selectedCells = [[row, col]];
      }

      String selectedWord = getSelectedWord();
      if (words.contains(selectedWord) && !foundWords.contains(selectedWord)) {
        foundWords.add(selectedWord);
        selectedCells.clear();
      }

      if (foundWords.length == words.length) {
        showGameOverDialog();
      }
    });
  }

  bool areAdjacent(List<int> cell1, List<int> cell2) {
    int rowDiff = (cell1[0] - cell2[0]).abs();
    int colDiff = (cell1[1] - cell2[1]).abs();
    return (rowDiff <= 1 && colDiff <= 1) && (rowDiff + colDiff > 0);
  }

  String getSelectedWord() {
    return selectedCells.map((cell) => grid[cell[0]][cell[1]]).join();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You found all the words!'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  startNewGame();
                });
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
        title: Text('Word Search', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                bool isSelected = selectedCells.any((cell) => cell[0] == row && cell[1] == col);
                return GestureDetector(
                  onTap: () => onCellSelected(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        grid[row][col],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words.map((word) {
                bool isFound = foundWords.contains(word);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFound ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}