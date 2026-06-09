import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/clinical_models.dart';

class ClinicalRisksScreen extends StatefulWidget {
  const ClinicalRisksScreen({super.key});

  @override
  State<ClinicalRisksScreen> createState() => _ClinicalRisksScreenState();
}

class _ClinicalRisksScreenState extends State<ClinicalRisksScreen> {
  // Simple Diabetes form variables for demonstration
  double _age = 30, _glucose = 110, _bmi = 24.5;
  String _resultText = '';

  void _calculateDiabetes() async {
    final api = Provider.of<ApiService>(context, listen: false);
    final input = DiabetesInput(
      pregnancies: 0, glucose: _glucose, bloodPressure: 70, 
      skinThickness: 0, insulin: 0, bmi: _bmi, pedigree: 0.47, age: _age
    );
    try {
      final res = await api.predictDiabetes(input);
      setState(() {
        _resultText = 'Diabetes Risk: ${res.riskPercentage}%';
      });
    } catch(e) {
      setState(() {
        _resultText = 'Error calculating risk';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clinical Risks'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Diabetes'),
              Tab(text: 'Heart'),
              Tab(text: 'Kidney'),
              Tab(text: 'Thyroid'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Diabetes Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('Assess your Type-2 Diabetes risk probability.'),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _age.toString(),
                    decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _age = double.tryParse(val) ?? 30,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _glucose.toString(),
                    decoration: const InputDecoration(labelText: 'Glucose Level', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _glucose = double.tryParse(val) ?? 110,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _bmi.toString(),
                    decoration: const InputDecoration(labelText: 'BMI', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _bmi = double.tryParse(val) ?? 24.5,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _calculateDiabetes, child: const Text('Calculate Diabetes Risk')),
                  const SizedBox(height: 24),
                  if (_resultText.isNotEmpty)
                    Text(_resultText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
            ),
            const Center(child: Text('Heart Disease Calculator Placeholder')),
            const Center(child: Text('Kidney Disease Calculator Placeholder')),
            const Center(child: Text('Thyroid Calculator Placeholder')),
          ],
        ),
      ),
    );
  }
}
