import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aquarium/database_helper.dart';

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
  double x; // Horizontal position
  double y; // Vertical position
  double dx; // Change in x direction
  double dy; // Change in y direction
  final double speed; // Speed of the fish
  final Color color; // Color of the fish

  Fish({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  })  : dx = Random().nextDouble() * 2 -
            1, // Random horizontal direction (-1 to 1)
        dy = Random().nextDouble() * 2 -
            1; // Random vertical direction (-1 to 1)

  double get angle => atan2(-dy, -dx); // Calculate angle based on direction

  void updatePosition(double width, double height) {
    x += dx * speed; // Move fish based on direction and speed
    y += dy * speed;

    // Check boundaries and reverse direction if necessary
    if (x <= 0) {
      x = 0; // Reset to left edge
      dx = -dx; // Reverse direction
    } else if (x >= width - 30) {
      x = width - 30; // Reset to right edge
      dx = -dx; // Reverse direction
    }

    if (y <= 0) {
      y = 0; // Reset to top edge
      dy = -dy; // Reverse direction
    } else if (y >= height - 30) {
      y = height - 30; // Reset to bottom edge
      dy = -dy; // Reverse direction
    }

    // Ensure the fish stays within the boundaries
    x = x.clamp(0, width - 30);
    y = y.clamp(0, height - 30);
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _fishCount = 0; // Store number of fish
  double? _selectedSpeed; // Variable to store selected speed
  final List<double> speedOptions = [
    0.5,
    1.0,
    2.0,
    4.0,
    8.0,
    16.0
  ]; // Speed options
  ColorLabel? _selectedColor;
  List<Fish> _fishList = []; // Change to List<Fish>
  Timer? _timer;

  late AnimationController _controller;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();

// Initialize the animation controller and set it to repeat indefinitely
    _controller = AnimationController(
      vsync: this, // Required for animation
      duration: const Duration(seconds: 1), // Duration for one sway cycle
    )..repeat(reverse: true); // Repeat the animation back and forth

    // Define the sway animation to go from -0.1 to 0.1 radians
    _swayAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadSettings(); // Load settings when the app starts
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseHelper().loadSettings();

    // Check if settings are not null and contain valid values
    if (settings != null) {
      setState(() {
        _selectedSpeed = settings['speed']; // Load saved speed
        // Ensure the color index is valid to avoid any out-of-bounds errors
        _selectedColor = settings['color'] >= 0 &&
                settings['color'] < ColorLabel.values.length
            ? ColorLabel.values[settings['color']]
            : ColorLabel
                .values[settings['color']]; // Default to green if invalid
      });
    } else {
      // Set default values if no settings were loaded
      _selectedSpeed = 1.0; // Set a sensible default
      _selectedColor = ColorLabel.green; // Set a sensible default
    }

    // Load individual fish details
    final loadedFish = await DatabaseHelper().loadFish();
    setState(() {
      _fishList = loadedFish;
      _fishCount = _fishList.length;
      if (_fishList.isNotEmpty) {
        _startTimer(); // Restart animation
      }
    });
  }

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
      _fishCount++;

      _startTimer(); // Start timer if not already started
    }
  }

  void _removeFish() {
    if (_fishList.isNotEmpty) {
      setState(() {
        final randomIndex = Random().nextInt(_fishList.length);
        _fishList.removeAt(randomIndex); // Remove a Fish object
        _fishCount--;
        if (_fishList.isEmpty) {
          _timer?.cancel(); // Stop the timer if no fish are left
        }
      });
    }
  }

  void _saveSettings() {
    DatabaseHelper().saveSettings(
      _fishCount,
      _selectedSpeed ?? 0.25,
      _selectedColor?.index ?? 0,
    );

    DatabaseHelper().saveFish(_fishList); // Save individual fish attributes
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  return AnimatedBuilder(
                    animation: _swayAnimation, // Link to sway animation
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(fish.x, fish.y) // Position the fish
                          ..rotateZ(fish.angle +
                              _swayAnimation.value), // Apply sway rotation
                        child: Container(
                          width: 30,
                          height: 30,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              fish.color.withOpacity(1.0), // Fish color
                              BlendMode.srcIn,
                            ),
                            child: Image.asset('assets/images/BlueFish.png'),
                          ),
                        ),
                      );
                    },
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
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveSettings,
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
