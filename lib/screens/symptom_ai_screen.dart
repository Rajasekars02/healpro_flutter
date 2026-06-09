import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/symptom_models.dart';

class SymptomAIScreen extends StatefulWidget {
  const SymptomAIScreen({super.key});

  @override
  State<SymptomAIScreen> createState() => _SymptomAIScreenState();
}

class _SymptomAIScreenState extends State<SymptomAIScreen> {
  List<String> _availableSymptoms = [];
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;
  DiagnoseInitiateResponse? _diagnoseResult;

  @override
  void initState() {
    super.initState();
    _fetchSymptoms();
  }

  Future<void> _fetchSymptoms() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final symptoms = await api.getSymptoms();
      setState(() {
        _availableSymptoms = symptoms;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.initiateDiagnose(SymptomRequest(symptoms: _selectedSymptoms));
      setState(() {
        _diagnoseResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Diagnoser'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Tell us how you feel. We will check your symptoms and ask follow-up questions.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            
            // Symptom Selection (Simplified for demo, you can use flutter_typeahead)
            DropdownButtonFormField<String>(
              hint: const Text('Select a symptom...'),
              items: _availableSymptoms.map((String sym) {
                return DropdownMenuItem(value: sym, child: Text(sym));
              }).toList(),
              onChanged: (val) {
                if (val != null && !_selectedSymptoms.contains(val)) {
                  setState(() => _selectedSymptoms.add(val));
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _selectedSymptoms.map((s) => Chip(
                label: Text(s),
                onDeleted: () {
                  setState(() => _selectedSymptoms.remove(s));
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedSymptoms.isEmpty || _isLoading ? null : _analyzeSymptoms,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Analyze Symptoms'),
            ),
            const SizedBox(height: 24),
            
            if (_diagnoseResult != null) ...[
              const Text('Possible Matches:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: _diagnoseResult!.matchingDiseases.length,
                  itemBuilder: (context, index) {
                    final match = _diagnoseResult!.matchingDiseases[index];
                    return Card(
                      child: ListTile(
                        title: Text(match.disease),
                        subtitle: Text('Score: ${(match.score * 100).toStringAsFixed(1)}%'),
                        trailing: Text(match.riskLevel),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
