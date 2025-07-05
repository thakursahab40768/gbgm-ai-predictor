import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GBGMPredictorApp());
}

class GBGMPredictorApp extends StatelessWidget {
  const GBGMPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBGM Predictor',
      home: const PredictorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PredictorPage extends StatefulWidget {
  const PredictorPage({super.key});

  @override
  State<PredictorPage> createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage> {
  final _controller = TextEditingController();
  String? _prediction;
  double? _confidence;

  Future<void> _predict() async {
    final history = _controller.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((e) => e != null)
        .toList();

    final url = Uri.parse('https://gbgm-ai-predictor.onrender.com/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'history': history}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _prediction = data['prediction'].toString();
        _confidence = data['confidence'];
      });
    } else {
      setState(() {
        _prediction = 'Error';
        _confidence = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GBGM Number Predictor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enter last 10 numbers (comma separated):'),
            TextField(controller: _controller),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _predict, child: const Text('Predict')),
            if (_prediction != null) ...[
              const SizedBox(height: 20),
              Text('Prediction: $_prediction'),
              Text('Confidence: ${_confidence?.toStringAsFixed(2)}%'),
            ],
          ],
        ),
      ),
    );
  }
}
