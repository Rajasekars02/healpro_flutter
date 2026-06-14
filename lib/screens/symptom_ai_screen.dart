import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/symptom_models.dart';

class SymptomAIScreen extends StatefulWidget {
  const SymptomAIScreen({super.key});

  @override
  State<SymptomAIScreen> createState() => _SymptomAIScreenState();
}

class _SymptomAIScreenState extends State<SymptomAIScreen> {
  List<String> _availableSymptoms = [
    'abdominal pain',
    'chest pain',
    'cough',
    'diarrhea',
    'dizziness',
    'fatigue',
    'fever',
    'headache',
    'joint pain',
    'muscle ache',
    'nausea',
    'rash',
    'shortness of breath',
    'sore throat',
    'vomiting'
  ];
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;
  bool _isFinalLoading = false;
  DiagnoseInitiateResponse? _diagnoseResult;
  DiagnosticMatch? _finalDiagnosis;

  @override
  void initState() {
    super.initState();
    _fetchSymptoms();
  }

  Future<void> _fetchSymptoms() async {
    try {
      final csvString = await rootBundle.loadString('assets/dataset.csv');
      final lines = csvString.split('\n');
      final Set<String> allSymptoms = {};
      
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        // In this CSV, the second column (symptoms) is always the first quoted string
        final match = RegExp(r'"([^"]+)"').firstMatch(line);
        if (match != null && match.group(1) != null) {
          final syms = match.group(1)!.split(',');
          for (var s in syms) {
            final clean = s.trim().toLowerCase();
            if (clean.isNotEmpty) {
              allSymptoms.add(clean);
            }
          }
        }
      }
      
      setState(() {
        _availableSymptoms = allSymptoms.toList()..sort();
      });
    } catch (e) {
      debugPrint('Error loading local symptoms: $e');
    }
  }

  void _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _finalDiagnosis = null; // Reset final diagnosis when inputs change
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.initiateDiagnose(SymptomRequest(symptoms: _selectedSymptoms));
      setState(() {
        _diagnoseResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _getFinalDiagnosis() async {
    if (_selectedSymptoms.isEmpty) return;

    setState(() => _isFinalLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final res = await api.finalDiagnose(SymptomRequest(symptoms: _selectedSymptoms));
      setState(() {
        _finalDiagnosis = res;
        _isFinalLoading = false;
      });
    } catch (e) {
      setState(() => _isFinalLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error getting final diagnosis: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _resetDiagnoser() {
    setState(() {
      _selectedSymptoms.clear();
      _diagnoseResult = null;
      _finalDiagnosis = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tell us how you feel',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_selectedSymptoms.isNotEmpty || _diagnoseResult != null || _finalDiagnosis != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _resetDiagnoser,
                            tooltip: 'Reset',
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We will analyze your symptoms, suggest follow-up questions, and help you get an initial diagnosis suggestion.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    
                    // Symptom autocomplete selector
                    _availableSymptoms.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _availableSymptoms.where((String option) {
                                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (String selection) {
                              if (!_selectedSymptoms.contains(selection)) {
                                setState(() {
                                  _selectedSymptoms.add(selection);
                                  _diagnoseResult = null;
                                  _finalDiagnosis = null;
                                });
                              }
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: 'Type a symptom (e.g., headache)...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty && !_selectedSymptoms.contains(value)) {
                                    setState(() {
                                      _selectedSymptoms.add(value);
                                      _diagnoseResult = null;
                                      _finalDiagnosis = null;
                                    });
                                    controller.clear();
                                  }
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Selected Symptoms Chips Wrap
            if (_selectedSymptoms.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Your Selected Symptoms:',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedSymptoms.map((s) => Chip(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  deleteIconColor: theme.colorScheme.primary,
                  label: Text(s),
                  onDeleted: () {
                    setState(() {
                      _selectedSymptoms.remove(s);
                      _diagnoseResult = null;
                      _finalDiagnosis = null;
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Analyze button (fallback if automatic trigger didn't fire)
            if (_selectedSymptoms.isNotEmpty && _diagnoseResult == null)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeSymptoms,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.analytics_outlined),
                label: const Text('Analyze Symptoms'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            
            // Follow-up Questions Section
            if (_diagnoseResult != null && _diagnoseResult!.questions.isNotEmpty && _finalDiagnosis == null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.amber.shade200, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          Text(
                            'Follow-up Questions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[900]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Do you also experience any of these common accompanying symptoms?',
                        style: TextStyle(color: Colors.amber[900], fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _diagnoseResult!.questions.map((q) => ActionChip(
                          avatar: const Icon(Icons.add, size: 16, color: Colors.amber),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.amber.shade300),
                          label: Text(q, style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w500)),
                          onPressed: () {
                            setState(() {
                              _selectedSymptoms.add(q);
                              _diagnoseResult = null;
                              _finalDiagnosis = null;
                            });
                          },
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Possible Matches
            if (_diagnoseResult != null && _finalDiagnosis == null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Potential Conditions',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (!_isLoading && _selectedSymptoms.isNotEmpty)
                    TextButton.icon(
                      onPressed: _isFinalLoading ? null : _getFinalDiagnosis,
                      icon: _isFinalLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Get Final Report'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _diagnoseResult!.matchingDiseases.length,
                      itemBuilder: (context, index) {
                        final match = _diagnoseResult!.matchingDiseases[index];
                        final scorePct = (match.score * 100).toStringAsFixed(1);
                        Color levelColor;
                        switch (match.riskLevel.toLowerCase()) {
                          case 'high':
                            levelColor = Colors.red;
                            break;
                          case 'moderate':
                          case 'medium':
                            levelColor = Colors.orange;
                            break;
                          default:
                            levelColor = Colors.green;
                        }
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: levelColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.medical_services_outlined, color: levelColor, size: 20),
                            ),
                            title: Text(match.disease, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Symptom overlap: $scorePct%'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: levelColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                match.riskLevel,
                                style: TextStyle(color: levelColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
            
            // Final Diagnosis Panel
            if (_finalDiagnosis != null) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shadowColor: Colors.purple.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.purple, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: const Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'AI Diagnostic Report',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _finalDiagnosis!.disease,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple[800]),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.purple.shade200),
                                ),
                                child: Text(
                                  'Score: ${(_finalDiagnosis!.score * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          
                          // Risk details
                          _buildDetailRow(
                            Icons.warning_amber_rounded,
                            'Risk Level',
                            _finalDiagnosis!.riskLevel,
                            _finalDiagnosis!.riskLevel.toLowerCase() == 'high' ? Colors.red : Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.people_outline,
                            'Specialist to Consult',
                            _finalDiagnosis!.doctor,
                            Colors.blue[800]!,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.healing_outlined,
                            'Recommended Care / Cure',
                            _finalDiagnosis!.cures,
                            Colors.green[800]!,
                          ),
                          
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _resetDiagnoser,
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Start Over'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.purple),
                                  foregroundColor: Colors.purple,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Report saved to history (Mock)'),
                                  ));
                                },
                                icon: const Icon(Icons.save_alt),
                                label: const Text('Save Report'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content, Color highlightColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: highlightColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
