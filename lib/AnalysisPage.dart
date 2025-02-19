import 'package:flutter/material.dart';
import 'SelectOption.dart'; // Import the SelectOption page

class VisualixHome extends StatefulWidget {
  const VisualixHome({Key? key}) : super(key: key);

  @override
  _VisualixHomeState createState() => _VisualixHomeState();
}

class _VisualixHomeState extends State<VisualixHome> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SelectOption(), // Navigate to SelectOption
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Visualix',
          style: TextStyle(
            fontSize: 36,
            color: Colors.blueGrey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}