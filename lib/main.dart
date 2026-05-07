import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const Game2048App());
}

class Game2048App extends StatefulWidget {
  const Game2048App({super.key});

  @override
  State<Game2048App> createState() => _Game2048AppState();
}

class _Game2048AppState extends State<Game2048App> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isSoundEnabled = true;
  final Map<int, int> _bestScores = {4: 0, 6: 0, 8: 0};

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleSound() {
    setState(() {
      _isSoundEnabled = !_isSoundEnabled;
    });
  }

  void _resetAllScores() {
    setState(() {
      _bestScores.updateAll((key, value) => 0);
    });
  }

  void _updateScore(int gridSize, int score) {
    if (score > (_bestScores[gridSize] ?? 0)) {
      setState(() {
        _bestScores[gridSize] = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = _themeMode == ThemeMode.dark;
    
    // Status bar style configuration
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark, // Dark icons for light mode
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      title: '2048',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfffaf8ef),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xff181a1b),
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child!,
        );
      },
      home: HomeScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
        isSoundEnabled: _isSoundEnabled,
        onSoundToggle: _toggleSound,
        onResetScores: _resetAllScores,
        bestScores: _bestScores,
        onUpdateScore: _updateScore,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool isSoundEnabled;
  final VoidCallback onSoundToggle;
  final VoidCallback onResetScores;
  final Map<int, int> bestScores;
  final Function(int, int) onUpdateScore;

  const HomeScreen({
    super.key, 
    required this.onThemeToggle, 
    required this.isDarkMode,
    required this.isSoundEnabled,
    required this.onSoundToggle,
    required this.onResetScores,
    required this.bestScores,
    required this.onUpdateScore,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? const Color(0xffe8e6e3) : const Color(0xff776e65);
    final Color buttonColor = isDarkMode ? const Color(0xff3e4446) : const Color(0xff8f7a66);
    final Color backgroundColor = isDarkMode ? const Color(0xff181a1b) : const Color(0xfffaf8ef);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: backgroundColor,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Roboto',
                  ),
                  child: const Text('2048'),
                ),
                const SizedBox(height: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor.withOpacity(0.8),
                    fontFamily: 'Roboto',
                  ),
                  child: const Text('Select Difficulty'),
                ),
                const SizedBox(height: 40),
                _buildDifficultyButton(context, 'Easy', '4 x 4', 4, buttonColor),
                _buildDifficultyButton(context, 'Medium', '6 x 6', 6, buttonColor),
                _buildDifficultyButton(context, 'Hard', '8 x 8', 8, buttonColor),
                const SizedBox(height: 40),
                IconButton.filled(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          isDarkMode: isDarkMode,
                          onThemeToggle: onThemeToggle,
                          isSoundEnabled: isSoundEnabled,
                          onSoundToggle: onSoundToggle,
                          onResetScores: onResetScores,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  style: IconButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, String size, int gridSize, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Game2048(
                  gridSize: gridSize,
                  onThemeToggle: onThemeToggle,
                  isDarkMode: isDarkMode,
                  isSoundEnabled: isSoundEnabled,
                  bestScore: bestScores[gridSize] ?? 0,
                  onUpdateScore: (score) => onUpdateScore(gridSize, score),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(size, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final bool isSoundEnabled;
  final VoidCallback onSoundToggle;
  final VoidCallback onResetScores;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.isSoundEnabled,
    required this.onSoundToggle,
    required this.onResetScores,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? const Color(0xffe8e6e3) : const Color(0xff776e65);
    final Color backgroundColor = isDarkMode ? const Color(0xff181a1b) : const Color(0xfffaf8ef);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: backgroundColor,
        child: ListView(
          children: [
            ListTile(
              leading: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey<bool>(isDarkMode),
                  color: textColor,
                ),
              ),
              title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) => onThemeToggle(),
                activeColor: const Color(0xff8f7a66),
              ),
            ),
            ListTile(
              leading: Icon(isSoundEnabled ? Icons.volume_up : Icons.volume_off, color: textColor),
              title: Text('Sound Effects', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              trailing: Switch(
                value: isSoundEnabled,
                onChanged: (_) => onSoundToggle(),
                activeColor: const Color(0xff8f7a66),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.redAccent),
              title: const Text('Reset High Scores', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Scores?'),
                    content: const Text('This will clear all your best scores forever.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          onResetScores();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scores reset successfully!')),
                          );
                        }, 
                        child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Game2048 extends StatefulWidget {
  final int gridSize;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool isSoundEnabled;
  final int bestScore;
  final Function(int) onUpdateScore;

  const Game2048({
    super.key, 
    required this.gridSize, 
    required this.onThemeToggle, 
    required this.isDarkMode,
    required this.isSoundEnabled,
    required this.bestScore,
    required this.onUpdateScore,
  });

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> with TickerProviderStateMixin {
  late List<int> grid;
  late int gridSize; 
  int score = 0;
  bool isGameOver = false;
  bool isWon = false;
  final FocusNode _focusNode = FocusNode();
  Offset _dragStart = Offset.zero;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;
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
        case Direction.left: moved = _moveLeft(); break;
        case Direction.right: moved = _moveRight(); break;
        case Direction.up: moved = _moveUp(); break;
        case Direction.down: moved = _moveDown(); break;
      }
      if (moved) {
        HapticFeedback.lightImpact();
        _addNewTile();
        widget.onUpdateScore(score);
        if (_checkGameOver()) isGameOver = true;
      }
    });
  }

  bool _moveLeft() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = 0; j < gridSize; j++) line.add(grid[i * gridSize + j]);
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) grid[i * gridSize + j] = newLine[j];
      }
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = gridSize - 1; j >= 0; j--) line.add(grid[i * gridSize + j]);
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) grid[i * gridSize + (gridSize - 1 - j)] = newLine[j];
      }
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = 0; j < gridSize; j++) line.add(grid[i + j * gridSize]);
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) grid[i + j * gridSize] = newLine[j];
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = gridSize - 1; j >= 0; j--) line.add(grid[i + j * gridSize]);
      List<int> newLine = _processLine(line);
      if (!_listEquals(line, newLine)) {
        moved = true;
        for (int j = 0; j < gridSize; j++) grid[i + (gridSize - 1 - j) * gridSize] = newLine[j];
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
    while (newLine.length < gridSize) newLine.add(0);
    return newLine;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
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
    if (widget.isDarkMode) {
      switch (value) {
        case 2: return const Color(0xff3e4446);
        case 4: return const Color(0xff4a5255);
        case 8: return const Color(0xfff2b179);
        case 16: return const Color(0xfff59563);
        case 32: return const Color(0xfff67c5f);
        case 64: return const Color(0xfff65e3b);
        case 128: return const Color(0xffedcf72);
        case 256: return const Color(0xffedcc61);
        case 512: return const Color(0xffedc850);
        case 1024: return const Color(0xffedc53f);
        case 2048: return const Color(0xffedc22e);
        default: return const Color(0xff2d3134);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double size = screenWidth * 0.95; 
    if (size > 600) size = 600;

    final Color primaryTextColor = widget.isDarkMode ? const Color(0xffe8e6e3) : const Color(0xff776e65);
    final Color gridContainerColor = widget.isDarkMode ? const Color(0xff3e4446) : const Color(0xffbbada0);
    final Color backgroundColor = widget.isDarkMode ? const Color(0xff181a1b) : const Color(0xfffaf8ef);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: backgroundColor,
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _handleSwipe(Direction.left);
              else if (event.logicalKey == LogicalKeyboardKey.arrowRight) _handleSwipe(Direction.right);
              else if (event.logicalKey == LogicalKeyboardKey.arrowUp) _handleSwipe(Direction.up);
              else if (event.logicalKey == LogicalKeyboardKey.arrowDown) _handleSwipe(Direction.down);
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: primaryTextColor),
                      ),
                      Column(
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTextColor, fontFamily: 'Roboto'),
                            child: const Text('2048'),
                          ),
                          Text('${gridSize}x${gridSize}', style: TextStyle(fontSize: 16, color: primaryTextColor)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildScoreBox('SCORE', score),
                          const SizedBox(width: 8),
                          _buildScoreBox('BEST', widget.bestScore),
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
                            if (delta.distance > 25.0) {
                              if (delta.dx.abs() > delta.dy.abs()) {
                                if (delta.dx > 0) _handleSwipe(Direction.right); else _handleSwipe(Direction.left);
                              } else {
                                if (delta.dy > 0) _handleSwipe(Direction.down); else _handleSwipe(Direction.up);
                              }
                              _hasMoved = true;
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: size,
                            height: size,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: gridContainerColor,
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
                              color: widget.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isWon ? 'You Win!' : 'Game Over!', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: primaryTextColor)),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBox(String label, int value) {
    final Color gridContainerColor = widget.isDarkMode ? const Color(0xff3e4446) : const Color(0xffbbada0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(minWidth: 60),
      decoration: BoxDecoration(
        color: gridContainerColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xffeee4da), fontWeight: FontWeight.bold, fontSize: 10)),
          Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTile(int value) {
    double fontSize = 32;
    if (gridSize == 6) fontSize = 18;
    if (gridSize == 8) fontSize = 12;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: AnimatedScale(
          scale: value == 0 ? 0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                value == 0 ? '' : '$value',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: value <= 4 && !widget.isDarkMode ? const Color(0xff776e65) : Colors.white,
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
