import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SnakeGameApp(),
    ),
  );
}

// --- DEPENDENCY INJECTION ---
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// --- MODELS ---
enum Direction { up, down, left, right }
enum GameStatus { initial, playing, paused, gameOver }

class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class GameState {
  final List<Point> snake;
  final Point food;
  final Direction direction;
  final GameStatus status;
  final int score;
  final int highScore;
  final int columns;
  final int rows;

  const GameState({
    required this.snake,
    required this.food,
    required this.direction,
    required this.status,
    required this.score,
    required this.highScore,
    required this.columns,
    required this.rows,
  });

  GameState copyWith({
    List<Point>? snake,
    Point? food,
    Direction? direction,
    GameStatus? status,
    int? score,
    int? highScore,
    int? columns,
    int? rows,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
    );
  }
}

// --- STATE MANAGEMENT ---
class GameController extends StateNotifier<GameState> {
  final SharedPreferences prefs;
  Timer? _timer;
  final int _speed = 120; // Milliseconds per tick

  GameController(this.prefs, int cols, int rows)
      : super(GameState(
          snake: [Point(cols ~/ 2, rows ~/ 2)],
          food: const Point(0, 0), // Will be set in init
          direction: Direction.up,
          status: GameStatus.initial,
          score: 0,
          highScore: prefs.getInt('highScore') ?? 0,
          columns: cols,
          rows: rows,
        )) {
    _spawnFood();
  }

  void _spawnFood() {
    final random = Random();
    Point newFood;
    do {
      newFood = Point(random.nextInt(state.columns), random.nextInt(state.rows));
    } while (state.snake.contains(newFood));
    state = state.copyWith(food: newFood);
  }

  void startGame() {
    if (state.status == GameStatus.playing) return;
    state = state.copyWith(
      status: GameStatus.playing,
      snake: [Point(state.columns ~/ 2, state.rows ~/ 2)],
      score: 0,
      direction: Direction.up,
    );
    _spawnFood();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) => _tick());
  }

  void pauseGame() {
    if (state.status == GameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _timer = Timer.periodic(Duration(milliseconds: _speed), (timer) => _tick());
    }
  }

  void changeDirection(Direction newDirection) {
    if (state.status != GameStatus.playing) return;
    
    // Prevent 180-degree turns
    if ((state.direction == Direction.up && newDirection == Direction.down) ||
        (state.direction == Direction.down && newDirection == Direction.up) ||
        (state.direction == Direction.left && newDirection == Direction.right) ||
        (state.direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    state = state.copyWith(direction: newDirection);
  }

  void _tick() {
    final head = state.snake.first;
    Point newHead;

    switch (state.direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    // Wall Collision Check
    if (newHead.x < 0 || newHead.x >= state.columns || newHead.y < 0 || newHead.y >= state.rows) {
      _gameOver();
      return;
    }

    // Self Collision Check
    if (state.snake.contains(newHead)) {
      _gameOver();
      return;
    }

    final newSnake = List<Point>.from(state.snake)..insert(0, newHead);

    // Food Check
    if (newHead == state.food) {
      final newScore = state.score + 10;
      final newHighScore = newScore > state.highScore ? newScore : state.highScore;
      if (newScore > state.highScore) {
        prefs.setInt('highScore', newHighScore);
      }
      state = state.copyWith(snake: newSnake, score: newScore, highScore: newHighScore);
      _spawnFood();
    } else {
      newSnake.removeLast();
      state = state.copyWith(snake: newSnake);
    }
  }

  void _gameOver() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    state = state.copyWith(status: GameStatus.gameOver);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // Grid size configuration
  return GameController(prefs, 15, 25);
});

// --- UI THEME ---
class AppColors {
  static const Color backgroundStart = Color(0xFF0F172A);
  static const Color backgroundEnd = Color(0xFF1E293B);
  static const Color primary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFF818CF8);
  static const Color snakeHead = Color(0xFF4ADE80);
  static const Color snakeBody = Color(0xFF22C55E);
  static const Color food = Color(0xFFF43F5E);
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}

// --- WIDGETS ---
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.glassBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ThemedBackground extends StatelessWidget {
  final Widget child;
  const ThemedBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// --- SCREENS ---
class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);

    return Scaffold(
      body: ThemedBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gamepad_rounded, size: 80, color: AppColors.primary)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(end: 1.1, duration: 1000.ms, curve: Curves.easeInOut),
              const SizedBox(height: 24),
              Text(
                'SNAKE',
                style: GoogleFonts.outfit(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'High Score: ${state.highScore}',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 64),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
                },
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  borderRadius: 32,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'PLAY NOW',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends ConsumerWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    // Auto-start game on entry if not playing/paused
    if (state.status == GameStatus.initial) {
      Future.microtask(() => controller.startGame());
    }

    return Scaffold(
      body: ThemedBackground(
        child: Column(
          children: [
            _buildHeader(context, state, controller),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) controller.changeDirection(Direction.down);
                  else if (details.delta.dy < 0) controller.changeDirection(Direction.up);
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) controller.changeDirection(Direction.right);
                  else if (details.delta.dx < 0) controller.changeDirection(Direction.left);
                },
                child: Center(
                  child: AspectRatio(
                    aspectRatio: state.columns / state.rows,
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          _buildGrid(state),
                          if (state.status == GameStatus.gameOver) _buildGameOver(context, controller, state),
                          if (state.status == GameStatus.paused) _buildPaused(controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState state, GameController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SCORE: ${state.score}',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(
              state.status == GameStatus.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              controller.pauseGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(GameState state) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.columns * state.rows,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.columns,
      ),
      itemBuilder: (context, index) {
        final x = index % state.columns;
        final y = index ~/ state.columns;
        final point = Point(x, y);

        if (point == state.food) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.food,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.food, blurRadius: 8, spreadRadius: 1)],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 800.ms),
          );
        }

        if (state.snake.contains(point)) {
          final isHead = state.snake.first == point;
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isHead ? AppColors.snakeHead : AppColors.snakeBody,
                borderRadius: BorderRadius.circular(isHead ? 8 : 4),
              ),
            ),
          );
        }

        // Empty grid cell (faint grid lines for premium feel)
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
        );
      },
    );
  }

  Widget _buildGameOver(BuildContext context, GameController controller, GameState state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.food),
              ),
              const SizedBox(height: 16),
              Text('Final Score: ${state.score}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home_rounded, size: 36),
                    onPressed: () {
                      Navigator.pop(context);
                      controller.state = controller.state.copyWith(status: GameStatus.initial);
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 36, color: AppColors.primary),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      controller.startGame();
                    },
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildPaused(GameController controller) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_outline_rounded, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text('PAUSED', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms),
      ),
    );
  }
}
