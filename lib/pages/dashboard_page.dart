
import 'package:flutter/material.dart';
import 'package:game_verse/pages/puzzle_game_page.dart';
import 'package:game_verse/pages/snake_game_page.dart';
import 'package:game_verse/pages/space_fighter_game_page.dart';
import 'package:game_verse/pages/sudoku_game_page.dart';
import 'package:game_verse/pages/tetris_game_page.dart';
import 'package:game_verse/pages/tic_tac_toe_page.dart';
import 'package:game_verse/pages/word_search_game_page.dart';

import 'bird_fly_game_page.dart';
import 'memory_game_page.dart';

class DashboardPage extends StatelessWidget {
  final List<GameInfo> games = [
    GameInfo(title: 'Tic Tac Toe', icon: Icons.grid_3x3, color: Colors.blue),
    GameInfo(title: 'Memory Game', icon: Icons.memory, color: Colors.green),
    GameInfo(title: 'Snake', icon: Icons.gesture, color: Colors.red),
    GameInfo(title: 'Puzzle', icon: Icons.extension, color: Colors.orange),
    GameInfo(title: 'Tetris', icon: Icons.layers, color: Colors.purple),
    GameInfo(title: 'Sudoku', icon: Icons.grid_on, color: Colors.teal),
    GameInfo(title: 'Word Search', icon: Icons.search, color: Colors.indigo),
    GameInfo(title: 'Space Fighter', icon: Icons.rocket_launch, color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildGameGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(Icons.add, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'GameVerse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1, // This ensures square tiles
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return GameCard(gameInfo: games[index],index: index,);
      },
    );
  }
}

class GameInfo {
  final String title;
  final IconData icon;
  final Color color;

  GameInfo({required this.title, required this.icon, required this.color});
}

class GameCard extends StatelessWidget {
  final GameInfo gameInfo;
  final int index;

  const GameCard({Key? key, required this.gameInfo,required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: gameInfo.color,
      child: InkWell(
        onTap: () {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TicTacToePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MemoryGamePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SnakeGamePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PuzzleGamePage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TetrisGamePage()),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SudokuGamePage()),
              );
              break;
            case 6:
              Navigator.push(context, MaterialPageRoute(builder: (context) => WordSearchGamePage()));
              break;
            case 7:
              Navigator.push(context, MaterialPageRoute(builder: (context) => SpaceFighterGamePage()));
              break;
          // Add more cases for other games when implemented
            default:
              print('Tapped on ${gameInfo.title}');
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(gameInfo.icon, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              gameInfo.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}