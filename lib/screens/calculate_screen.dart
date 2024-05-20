import 'package:flutter/material.dart';

class CalculateScreen extends StatefulWidget {
  const CalculateScreen({super.key});

  @override
  CalculateScreenState createState() => CalculateScreenState();
}

class CalculateScreenState extends State<CalculateScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  double _bmiResult = 0;
  double _idealBodyWeightResult = 0;
  double _dailyCalorieIntakeResult = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perhitungan Kalori'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'BMI Calculator'),
              Tab(text: 'Ideal Body Weight'),
              Tab(text: 'Daily Calorie Intake'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBMI(),
            _buildIdealBodyWeight(),
            _buildDailyCalorieIntake(),
          ],
        ),
      ),
    );
  }

  Widget _buildBMI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Berat (kg)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tinggi (cm)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _calculateBMI();
            },
            child: const Text('Hitung BMI'),
          ),
          const SizedBox(height: 16),
          Text(
            'BMI: $_bmiResult',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildIdealBodyWeight() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tinggi (cm)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _calculateIdealBodyWeight();
            },
            child: const Text('Hitung Berat Badan Ideal'),
          ),
          const SizedBox(height: 16),
          Text(
            'Berat Badan Ideal: $_idealBodyWeightResult kg',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCalorieIntake() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Berat (kg)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tinggi (cm)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Usia',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _calculateDailyCalorieIntake();
            },
            child: const Text('Hitung Kebutuhan Kalori Harian'),
          ),
          const SizedBox(height: 16),
          Text(
            'Kebutuhan Kalori Harian: $_dailyCalorieIntakeResult',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;

    setState(() {
      _bmiResult = weight / ((height / 100) * (height / 100));
    });
  }

  void _calculateIdealBodyWeight() {
    double height = double.tryParse(_heightController.text) ?? 0;

    setState(() {
      _idealBodyWeightResult = (height - 100) - ((height - 100) * 0.1);
    });
  }

  void _calculateDailyCalorieIntake() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    int age = int.tryParse(_ageController.text) ?? 0;

    setState(() {
      _dailyCalorieIntakeResult =
          (10 * weight) + (6.25 * height) - (5 * age) + 5;
    });
  }
}
