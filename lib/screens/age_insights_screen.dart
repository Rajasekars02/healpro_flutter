import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import '../services/health_history_service.dart';
import '../theme/app_theme.dart';

class AgeInsightsScreen extends StatefulWidget {
  const AgeInsightsScreen({super.key});

  @override
  State<AgeInsightsScreen> createState() => _AgeInsightsScreenState();
}

class _AgeInsightsScreenState extends State<AgeInsightsScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmiResult;
  bool _useCm = true; // metric vs. imperial

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h == null || w == null || h <= 0 || w <= 0) return;

    double bmi;
    if (_useCm) {
      bmi = w / pow(h / 100, 2);
    } else {
      // inches / lbs
      bmi = (703 * w) / pow(h, 2);
    }
    setState(() => _bmiResult = bmi);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal Weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return AppTheme.riskLow;
    if (bmi < 30.0) return AppTheme.riskModerate;
    return AppTheme.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileService>();
    final history = context.watch<HealthHistoryService>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final age = profile.age;
    final decades = _getDecadeContent(age);

    return Scaffold(

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Personalized Greeting ─────────────────────────────────────────
          if (profile.hasProfile) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary.withOpacity(0.85), cs.secondary.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.25),
                        radius: 22,
                        child: Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi, ${profile.name}!', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                            Text('Age $age · ${profile.gender}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    decades.headline,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    decades.summary,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: cs.primary),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Set your profile in Settings to get personalized age insights.')),
                    TextButton(onPressed: null, child: const Text('→ Settings')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Latest Risk Snapshot ──────────────────────────────────────────
          if (history.latestByType.isNotEmpty) ...[
            Text('Your Latest Risk Snapshot', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: history.latestByType.entries.map((e) {
                final color = history.riskColor(e.value.riskPercentage);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 12)),
                      Text(
                        '${e.value.riskPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
                      ),
                      Text(history.riskLabel(e.value.riskPercentage),
                          style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── BMI Calculator ────────────────────────────────────────────────
          Text('BMI Calculator', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Unit toggle
                  Row(
                    children: [
                      const Text('Unit:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Metric (cm/kg)')),
                          ButtonSegment(value: false, label: Text('Imperial (in/lbs)')),
                        ],
                        selected: {_useCm},
                        onSelectionChanged: (sel) => setState(() {
                          _useCm = sel.first;
                          _bmiResult = null;
                          _heightController.clear();
                          _weightController.clear();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: 'Height',
                            suffixText: _useCm ? 'cm' : 'in',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight',
                            suffixText: _useCm ? 'kg' : 'lbs',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculateBMI,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calculate BMI'),
                    ),
                  ),
                  if (_bmiResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _bmiColor(_bmiResult!).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _bmiColor(_bmiResult!).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _bmiResult!.toStringAsFixed(1),
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: _bmiColor(_bmiResult!)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bmiCategory(_bmiResult!),
                                  style: TextStyle(fontWeight: FontWeight.w700, color: _bmiColor(_bmiResult!), fontSize: 16),
                                ),
                                Text(_bmiAdvice(_bmiResult!), style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6), height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // BMI scale bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ((_bmiResult! - 10) / 30).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(_bmiColor(_bmiResult!)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('10', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          Text('Healthy: 18.5–24.9', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          Text('40+', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Decade Cards ──────────────────────────────────────────────────
          Text('Age-Based Health Guide', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._allDecades.map((d) => _DecadeCard(
            data: d,
            isCurrentDecade: age >= d.ageStart && age < d.ageEnd,
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _bmiAdvice(double bmi) {
    if (bmi < 18.5) return 'Consider increasing calorie intake with nutrient-rich foods.';
    if (bmi < 25.0) return 'Great work! Keep up your healthy lifestyle habits.';
    if (bmi < 30.0) return 'Consider light exercise and mindful eating habits.';
    return 'Consult your physician about a healthy weight management plan.';
  }

  _DecadeData _getDecadeContent(int age) {
    return _allDecades.firstWhere(
      (d) => age >= d.ageStart && age < d.ageEnd,
      orElse: () => _allDecades.last,
    );
  }
}

// ── Data models ────────────────────────────────────────────────────────────────

class _DecadeData {
  final String label;
  final int ageStart;
  final int ageEnd;
  final String headline;
  final String summary;
  final List<String> tips;
  final List<String> screenings;
  final Color color;

  const _DecadeData({
    required this.label,
    required this.ageStart,
    required this.ageEnd,
    required this.headline,
    required this.summary,
    required this.tips,
    required this.screenings,
    required this.color,
  });
}

const List<_DecadeData> _allDecades = [
  _DecadeData(
    label: '20s', ageStart: 18, ageEnd: 30,
    headline: 'Building healthy foundations',
    summary: 'Your 20s are the prime time to establish lifestyle habits that will protect you for decades.',
    color: Color(0xFF22C55E),
    tips: ['Establish a regular sleep schedule (7–9 hrs)', 'Build an exercise routine', 'Limit processed foods & alcohol', 'Manage stress proactively'],
    screenings: ['Blood pressure check', 'Cholesterol baseline', 'STI screenings (if applicable)', 'Dental & eye exams annually'],
  ),
  _DecadeData(
    label: '30s', ageStart: 30, ageEnd: 40,
    headline: 'Sustaining momentum',
    summary: 'Metabolism begins to slow. Muscle mass becomes harder to maintain — prioritise strength training.',
    color: Color(0xFF3B82F6),
    tips: ['Add resistance training 2–3x / week', 'Monitor weight trends', 'Prioritise mental health', 'Check thyroid if symptoms appear'],
    screenings: ['Fasting blood glucose', 'Thyroid function (TSH)', 'Skin cancer screening', 'Pap smear / prostate awareness'],
  ),
  _DecadeData(
    label: '40s', ageStart: 40, ageEnd: 50,
    headline: 'Proactive screenings matter',
    summary: 'Risks for diabetes, cardiovascular disease, and hormonal changes increase. Regular check-ups are essential.',
    color: Color(0xFFF59E0B),
    tips: ['Annual blood panel (glucose, lipids, kidney)', 'Reduce saturated fat intake', 'Begin mindfulness / yoga practice', 'Regular cardiac ECG if family history'],
    screenings: ['Colonoscopy (first)', 'Mammogram (age 40–44 per guidelines)', 'Blood glucose & HbA1c', 'Blood pressure every 6 months'],
  ),
  _DecadeData(
    label: '50s', ageStart: 50, ageEnd: 60,
    headline: 'Cardiovascular and bone health focus',
    summary: 'Heart disease and osteoporosis risks rise significantly. Medication reviews and lifestyle maintenance are key.',
    color: Color(0xFFF97316),
    tips: ['Prioritise calcium & vitamin D', 'Take statin if prescribed', 'Stay socially active', 'Avoid smoking entirely'],
    screenings: ['DEXA bone density scan', 'Coronary calcium score', 'Lung cancer CT (if smoker)', 'Colonoscopy every 10 yrs'],
  ),
  _DecadeData(
    label: '60s', ageStart: 60, ageEnd: 70,
    headline: 'Managing chronic conditions',
    summary: 'Focus on mobility, fall prevention, and actively managing any diagnosed chronic conditions.',
    color: Color(0xFFEF4444),
    tips: ['Balance & strength exercises', 'Review all medications with doctor', 'Hearing & vision checks', 'Social engagement reduces cognitive decline'],
    screenings: ['Annual kidney function (eGFR)', 'Aortic aneurysm screening (men)', 'Cognitive assessment baseline', 'Eye pressure (glaucoma)'],
  ),
  _DecadeData(
    label: '70+', ageStart: 70, ageEnd: 200,
    headline: 'Quality of life and independence',
    summary: 'Focus on maintaining independence, fall prevention, cognitive health, and optimising chronic disease management.',
    color: Color(0xFF8B5CF6),
    tips: ['Fall-proof your home', 'Stay hydrated (thirst reflex reduces with age)', 'Engage in cognitive games', 'Palliative care planning if needed'],
    screenings: ['Annual comprehensive geriatric assessment', 'Frailty screening', 'Vision & hearing annually', 'Vaccination reviews (flu, shingles, pneumonia)'],
  ),
];

// ── Widget ─────────────────────────────────────────────────────────────────────

class _DecadeCard extends StatefulWidget {
  final _DecadeData data;
  final bool isCurrentDecade;
  const _DecadeCard({required this.data, required this.isCurrentDecade});

  @override
  State<_DecadeCard> createState() => _DecadeCardState();
}

class _DecadeCardState extends State<_DecadeCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isCurrentDecade; // Auto-expand current decade
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: widget.isCurrentDecade
            ? BorderSide(color: d.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: d.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(d.label, style: TextStyle(fontWeight: FontWeight.w800, color: d.color, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(d.headline, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                            if (widget.isCurrentDecade)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: d.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Your Age', style: TextStyle(fontSize: 10, color: d.color, fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(d.summary,
                          maxLines: _expanded ? 5 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6), height: 1.3)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: cs.onSurface.withOpacity(0.4)),
                ],
              ),
            ),

            // Expanded content
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _expandedSection('💡 Healthy Habits', d.tips, d.color),
                    const SizedBox(height: 12),
                    _expandedSection('🩺 Recommended Screenings', d.screenings, d.color),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _expandedSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.35))),
            ],
          ),
        )),
      ],
    );
  }
}
