import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Deluxe',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const Game2048(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> with TickerProviderStateMixin {
  late List<int> grid;
  int gridSize = 4; 
  int score = 0;
  
  // Store best scores for each grid size separately (3x3 to 8x8)
  final Map<int, int> bestScores = {3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0};
  
  bool isGameOver = false;
  bool isWon = false;
  final FocusNode _focusNode = FocusNode();
  
  Offset _dragStart = Offset.zero;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    grid = List.filled(gridSize * gridSize, 0);
    _resetGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      grid = List.filled(gridSize * gridSize, 0);
      score = 0;
      isGameOver = false;
      isWon = false;
      _addNewTile();
      _addNewTile();
    });
  }

  void _addNewTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == 0) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int index = emptyIndices[Random().nextInt(emptyIndices.length)];
      grid[index] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _handleSwipe(Direction direction) {
    if (isGameOver) return;

    bool moved = false;
    setState(() {
      switch (direction) {
        case Direction.left:
          moved = _moveLeft();
          break;
        case Direction.right:
          moved = _moveRight();
          break;
        case Direction.up:
          moved = _moveUp();
          break;
        case Direction.down:
          moved = _moveDown();
          break;
      }

      if (moved) {
        HapticFeedback.lightImpact();
        _addNewTile();
        
        if (score > bestScores[gridSize]!) {
          bestScores[gridSize] = score;
        }
        
        if (_checkGameOver()) {
          isGameOver = true;
        }
      }
    });
  }

  bool _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = 0; j < gridSize; j++) {
        line.add(grid[i * gridSize + j]);
      }
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) {
          grid[i * gridSize + j] = newLine[j];
        }
      }
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = gridSize - 1; j >= 0; j--) {
        line.add(grid[i * gridSize + j]);
      }
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) {
          grid[i * gridSize + (gridSize - 1 - j)] = newLine[j];
        }
      }
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = 0; j < gridSize; j++) {
        line.add(grid[i + j * gridSize]);
      }
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) {
          grid[i + j * gridSize] = newLine[j];
        }
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = gridSize - 1; j >= 0; j--) {
        line.add(grid[i + j * gridSize]);
      }
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) {
          grid[i + (gridSize - 1 - j) * gridSize] = newLine[j];
        }
      }
    }
    return moved;
  }

  List<int> _processLine(List<int> line) {
    List<int> newLine = line.where((x) => x != 0).toList();
    for (int i = 0; i < newLine.length - 1; i++) {
      if (newLine[i] == newLine[i + 1]) {
        newLine[i] *= 2;
        score += newLine[i];
        if (newLine[i] == 2048) isWon = true;
        newLine.removeAt(i + 1);
      }
    }
    while (newLine.length < gridSize) {
      newLine.add(0);
    }
    return newLine;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _checkGameOver() {
    if (grid.contains(0)) return false;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (grid[i * gridSize + j] == grid[i * gridSize + j + 1]) return false;
        if (grid[j * gridSize + i] == grid[(j + 1) * gridSize + i]) return false;
      }
    }
    return true;
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xffeee4da);
      case 4: return const Color(0xffeee1c9);
      case 8: return const Color(0xfff2b179);
      case 16: return const Color(0xfff59563);
      case 32: return const Color(0xfff67c5f);
      case 64: return const Color(0xfff65e3b);
      case 128: return const Color(0xffedcf72);
      case 256: return const Color(0xffedcc61);
      case 512: return const Color(0xffedc850);
      case 1024: return const Color(0xffedc53f);
      case 2048: return const Color(0xffedc22e);
      default: return const Color(0xffcdc1b4);
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Grid Size'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [3, 4, 5, 6, 7, 8].map((size) {
                return ListTile(
                  title: Text('$size x $size'),
                  leading: Radio<int>(
                    value: size,
                    groupValue: gridSize,
                    onChanged: (value) {
                      setState(() {
                        gridSize = value!;
                        _initGrid();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      gridSize = size;
                      _initGrid();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenWidth * 0.95; 
    if (size > 600) size = 600;

    return Scaffold(
      backgroundColor: const Color(0xfffaf8ef),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _handleSwipe(Direction.left);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _handleSwipe(Direction.right);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _handleSwipe(Direction.up);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _handleSwipe(Direction.down);
            }
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0), // Increased vertical padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2048', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xff776e65))),
                        Text('${gridSize}x${gridSize} Mode', style: const TextStyle(fontSize: 18, color: Color(0xff776e65))),
                      ],
                    ),
                    Row(
                      children: [
                        _buildScoreBox('SCORE', score),
                        const SizedBox(width: 10), // Increased gap
                        _buildScoreBox('BEST', bestScores[gridSize]!),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          _dragStart = details.localPosition;
                          _hasMoved = false;
                        },
                        onPanUpdate: (details) {
                          if (_hasMoved) return;
                          final delta = details.localPosition - _dragStart;
                          const double threshold = 25.0; 
                          if (delta.distance > threshold) {
                            if (delta.dx.abs() > delta.dy.abs()) {
                              if (delta.dx > 0) _handleSwipe(Direction.right);
                              else _handleSwipe(Direction.left);
                            } else {
                              if (delta.dy > 0) _handleSwipe(Direction.down);
                              else _handleSwipe(Direction.up);
                            }
                            _hasMoved = true;
                          }
                        },
                        child: Container(
                          width: size,
                          height: size,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xffbbada0),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: gridSize * gridSize,
                            itemBuilder: (context, index) {
                              return _buildTile(grid[index]);
                            },
                          ),
                        ),
                      ),
                      if (isGameOver || isWon)
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isWon ? 'You Win!' : 'Game Over!',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xff776e65)),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff8f7a66),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: const Text('Try Again', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8f7a66),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      onPressed: _showSettings,
                      icon: const Icon(Icons.settings),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xffbbada0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // Increased padding
      constraints: const BoxConstraints(minWidth: 80), // Added minimum width for balance
      decoration: BoxDecoration(
        color: const Color(0xffbbada0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xffeee4da), fontWeight: FontWeight.bold, fontSize: 12)), // Larger label
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), // Larger value
        ],
      ),
    );
  }

  Widget _buildTile(int value) {
    double fontSize = 32;
    if (gridSize == 5) fontSize = 24;
    if (gridSize == 6) fontSize = 18;
    if (gridSize >= 7) fontSize = 14;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: AnimatedScale(
          scale: value == 0 ? 0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                value == 0 ? '' : '$value',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: value <= 4 ? const Color(0xff776e65) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
