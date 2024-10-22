import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Aquarium App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

class Fish {
  double x;
  double y;
  double dx;
  double dy;
  final double speed;
  final Color color;

  Fish({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  })  : dx = Random().nextBool()
            ? 1
            : -1 * (speed / 2), // Direction based on speed
        dy = Random().nextBool()
            ? 1
            : -1 * (speed / 2); // Direction based on speed

  void updatePosition(double width, double height) {
    x += dx; // Apply speed directly as direction is already set
    y += dy;

    // Check boundaries and reverse direction
    if (x <= 0) {
      x = 0; // Reset to left edge
      dx = speed; // Set direction based on speed
    } else if (x >= width - 30) {
      x = width - 30; // Reset to right edge
      dx = -speed; // Set direction based on speed
    }

    if (y <= 0) {
      y = 0; // Reset to top edge
      dy = speed; // Set direction based on speed
    } else if (y >= height - 30) {
      y = height - 30; // Reset to bottom edge
      dy = -speed; // Set direction based on speed
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double? _selectedSpeed; // Variable to store selected speed
  final List<double> speedOptions = [0.5, 1.0, 1.5, 2.0, 2.5]; // Speed options
  ColorLabel? _selectedColor;
  List<Fish> _fishList = []; // Change to List<Fish>
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var fish in _fishList) {
          fish.updatePosition(300, 300); // Update fish position
        }
      });
    });
  }

  void _addFish() {
    if (_selectedSpeed != null &&
        _selectedColor != null &&
        _fishList.length < 10) {
      final random = Random();
      _fishList.add(Fish(
        x: random.nextDouble() * 250, // Random initial x position
        y: random.nextDouble() * 250, // Random initial y position
        speed: _selectedSpeed!, // Use the selected speed
        color: _selectedColor!.color,
      ));
      _startTimer(); // Start timer if not already started
    }
  }

  void _removeFish() {
    if (_fishList.isNotEmpty) {
      setState(() {
        final randomIndex = Random().nextInt(_fishList.length);
        _fishList.removeAt(randomIndex); // Remove a Fish object
        if (_fishList.isEmpty) {
          _timer?.cancel(); // Stop the timer if no fish are left
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 3.0,
                ),
              ),
              child: Stack(
                children: _fishList.map((fish) {
                  return Positioned(
                    left: fish.x, // Use the stored x position
                    top: fish.y, // Use the stored y position
                    child: Container(
                      width: 30,
                      height: 30,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          fish.color
                              .withOpacity(1.0), // Use the selected fish color
                          BlendMode.srcIn, // Blend mode to apply
                        ),
                        child: Image.asset(
                          'assets/images/BlueFish.png',
                          // Make sure the image color doesn't interfere
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addFish,
                  child: const Text('Add Fish'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _removeFish,
                  child: const Text('Kill Fish'),
                ),
                const SizedBox(width: 10),
                const ElevatedButton(
                  onPressed: DoNothingAction.new,
                  child: Text('Save Settings'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fish Speed:  ',
                  style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                DropdownButton<double>(
                  hint: const Text("Select Fish Speed"),
                  value: _selectedSpeed,
                  dropdownColor: Colors.white,
                  focusColor: Colors.white,
                  items: speedOptions.map((double speed) {
                    return DropdownMenuItem<double>(
                      value: speed,
                      child: Text(
                        speed.toString(),
                        style: TextStyle(color: Colors.purple),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSpeed = newValue; // Update selected speed
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fish Color:  ',
                  style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                DropdownButton<ColorLabel>(
                  hint: const Text("Select Fish Color"),
                  value: _selectedColor,
                  dropdownColor: Colors.white,
                  focusColor: Colors.white,
                  items: ColorLabel.values.map((ColorLabel colorLabel) {
                    return DropdownMenuItem<ColorLabel>(
                      value: colorLabel,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: colorLabel.color,
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          Text(
                            colorLabel.label,
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedColor = newValue; // Update selected color
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
