import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChessBoardController _controller = ChessBoardController();
  late Timer _timer;
  int _remainingTime = 300; // Total time in seconds (5 minutes)
  int _score = 100; // Initial score
  bool _isTimerRunning = false; // Flag to check if timer is running

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      debugPrint('Current Board State (FEN): ${_controller.getFen()}');
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void startTimer() {
    if (_isTimerRunning) return; // Do not start the timer if it's already running

    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _score = (_score - 1).clamp(0, 100); // Reduce score by 1 per second, ensure it doesn't go below 0
        } else {
          _timer.cancel();
          _isTimerRunning = false;
          showGameOverDialog();
        }
      });
    });
  }

  void stopTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    }
  }

  void toggleTimer() {
    if (_isTimerRunning) {
      stopTimer(); // Stop the timer if it's running
    } else {
      startTimer(); // Start the timer if it's not running
    }
  }

  void resetGame() {
    _controller.resetBoard();
    setState(() {
      _remainingTime = 300; // Reset timer to 5 minutes
      _score = 100; // Reset score to 100
    });
    stopTimer(); // Stop the current timer
    startTimer(); // Start the timer again after reset
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Over'),
        content: Text('The time for this game has ended.\nYour final score is: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Chess Game',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Time Remaining: ${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Score: $_score',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ChessBoard(
              controller: _controller,
              boardColor: BoardColor.darkBrown,
              boardOrientation: PlayerColor.white,
              arrows: [
                BoardArrow(
                  from: 'e2',
                  to: 'e4',
                  color: Colors.green.withOpacity(0.8),
                ),
                BoardArrow(
                  from: 'b8',
                  to: 'c6',
                  color: Colors.blue.withOpacity(0.8),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: resetGame,
                  child: const Text('Reset Board'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _controller.undoMove();
                    debugPrint('Last Move Undone');
                  },
                  child: const Text('Undo Move'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: toggleTimer, // Use the toggleTimer method
                  child: Text(
                    _isTimerRunning ? 'Stop Timer' : 'Start Timer',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
