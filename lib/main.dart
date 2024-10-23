// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with TickerProviderStateMixin {
  List<Fish> fishList = [];
  String selectedFishImage = 'assets/fish1.png';
  double selectedSpeed = 0.01; // Start with an extremely slow speed
  final int maxFishCount = 10; // Limit to 10 fish

  // Add new fish to the aquarium
  void _addFish() {
    if (fishList.length < maxFishCount) {
      setState(() {
        Fish newFish = Fish(
          imagePath: selectedFishImage,
          speed: selectedSpeed,
          vsync: this,
        );
        fishList.add(newFish);
        newFish.startAnimation(); // Start the animation when fish is added
      });
    } else {
      // Show a message if the fish count exceeds the limit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more than $maxFishCount fish.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Update speed for all fish
  void _updateFishSpeed() {
    for (var fish in fishList) {
      fish.updateSpeed(selectedSpeed);
    }
  }

  @override
  void dispose() {
    // Dispose of all animation controllers
    for (var fish in fishList) {
      fish.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          // Aquarium container with a background
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/aquarium_background.png'), // Add a background image for the aquarium
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.blue.shade800, width: 4),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: fishList.map((fish) => fish.buildFish()).toList(),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Fish count: ${fishList.length}/$maxFishCount', // Display fish count
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          // Control panel for adding fish, adjusting image, speed
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        // Fish image selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select Fish: "),
            DropdownButton<String>(
              value: selectedFishImage,
              items: <String>[
                'assets/fish1.png',
                'assets/fish2.png',
                'assets/fish3.png',
                'assets/fish4.png',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Image.asset(
                    value,
                    width: 60, // Larger image in the dropdown
                    height: 60,
                  ),
                );
              }).toList(),
              onChanged: (String? newFishImage) {
                setState(() {
                  selectedFishImage = newFishImage ?? 'assets/fish1.png';
                });
              },
            ),
          ],
        ),
        // Fish speed slider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Fish Speed: "),
            Slider(
              value: selectedSpeed,
              min: 0.001, // Extremely slow speed
              max: 1.0, // Faster speeds if desired
              divisions: 1000,
              label: selectedSpeed.toStringAsFixed(3),
              onChanged: (double newSpeed) {
                setState(() {
                  selectedSpeed = newSpeed;
                  _updateFishSpeed(); // Update speed dynamically for all fish
                });
              },
            ),
          ],
        ),
        // Add fish button
        ElevatedButton(
          onPressed: _addFish,
          child: Text('Add Fish'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 167, 187, 209),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

class Fish {
  final String imagePath;
  double speed;
  late AnimationController controller;
  double posX = 0;
  double posY = 0;
  double directionX = 1; // Direction for X movement (1 for right, -1 for left)
  double directionY = 1; // Direction for Y movement (1 for down, -1 for up)

  Fish(
      {required this.imagePath,
      required this.speed,
      required TickerProvider vsync}) {
    controller = AnimationController(
      duration: Duration(milliseconds: 16), // ~60 frames per second
      vsync: vsync,
    );

    controller.addListener(() {
      // Update position based on the direction and speed
      posX += directionX * speed * 10; // Multiply by speed factor
      posY += directionY * speed * 10;

      // Bounce off the edges
      if (posX <= 0 || posX >= 200) {
        // Adjust boundary to the container size
        directionX = -directionX; // Reverse direction on X-axis
      }
      if (posY <= 0 || posY >= 200) {
        // Adjust boundary to the container size
        directionY = -directionY; // Reverse direction on Y-axis
      }
    });
  }

  void startAnimation() {
    controller.repeat(); // Continuous movement
  }

  // Method to update the speed dynamically
  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  Widget buildFish() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: posX,
          top: posY,
          child: child!,
        );
      },
      child: Image.asset(
        imagePath,
        width: 100, // Larger fish image for better visibility
        height: 100,
      ),
    );
  }
}
