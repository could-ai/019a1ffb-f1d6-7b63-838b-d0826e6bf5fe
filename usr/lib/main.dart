import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RoulettePredictorPage(),
    );
  }
}

class RoulettePredictorPage extends StatefulWidget {
  const RoulettePredictorPage({super.key});

  @override
  State<RoulettePredictorPage> createState() => _RoulettePredictorPageState();
}

class _RoulettePredictorPageState extends State<RoulettePredictorPage> {
  final TextEditingController _numberController = TextEditingController();
  final List<int> _enteredNumbers = [];
  List<int> _predictedNumbers = [];

  void _addNumber() {
    final String input = _numberController.text;
    if (input.isEmpty) return;

    final int? number = int.tryParse(input);
    if (number != null && number >= 0 && number <= 36) {
      setState(() {
        _enteredNumbers.add(number);
        _calculatePredictions();
      });
      _numberController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number between 0 and 36.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculatePredictions() {
    if (_enteredNumbers.isEmpty) {
      _predictedNumbers = [];
      return;
    }

    final Map<int, int> frequencies = {};
    for (var number in _enteredNumbers) {
      frequencies[number] = (frequencies[number] ?? 0) + 1;
    }

    final sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topNumbers = sortedEntries.map((e) => e.key).toList();

    // If not enough unique numbers, add some random ones to complete the list of 5
    final random = Random();
    while (topNumbers.length < 5) {
      final randomNumber = random.nextInt(37);
      if (!topNumbers.contains(randomNumber)) {
        topNumbers.add(randomNumber);
      }
    }

    setState(() {
      _predictedNumbers = topNumbers.take(5).toList();
    });
  }

  void _clearNumbers() {
    setState(() {
      _enteredNumbers.clear();
      _predictedNumbers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette Predictor'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            _buildHistorySection(),
            const SizedBox(height: 24),
            _buildPredictionSection(),
            const Spacer(),
            ElevatedButton(
              onPressed: _clearNumbers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Last Winning Number',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _addNumber(),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _addNumber,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entered Numbers:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _enteredNumbers.isEmpty
              ? const Center(
                  child: Text('No numbers entered yet.'),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _enteredNumbers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Chip(
                        label: Text(
                          _enteredNumbers[index].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPredictionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predicted Winning Numbers:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _predictedNumbers.isEmpty
            ? const Text('Enter a number to see predictions.')
            : Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _predictedNumbers.map((number) {
                  return Chip(
                    label: Text(
                      number.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(12),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
