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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double? _selectedSpeed; // Variable to store selected speed
  final List<double> speedOptions = [1.0, 2.0, 3.0, 4.0, 5.0]; // Speed options
  ColorLabel? _selectedColor;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
                  color: Colors.blue, // Border color
                  width: 3.0, // Border width
                ),
              ),
              child: Text(
                'Fish here',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: DoNothingAction.new,
                  child: Text('Add Fish'),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: DoNothingAction.new,
                  child: Text('Kill Fish'),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
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
                            color: colorLabel.color, // Color preview box
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          Text(
                            colorLabel.label, // Display color name
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
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
