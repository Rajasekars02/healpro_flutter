import 'package:flutter/material.dart';

class AgeInsightsScreen extends StatelessWidget {
  const AgeInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'How age progression affects chronic disease risks.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _buildDecadeCard(context, '20s', 'Focus on establishing healthy habits, baseline blood pressure, and cholesterol checks.'),
            _buildDecadeCard(context, '40s', 'Metabolism slows. Begin regular screenings for diabetes and thyroid issues.'),
            _buildDecadeCard(context, '60s', 'Increased cardiovascular risk. Strict monitoring of kidney and heart functions is advised.'),
            _buildDecadeCard(context, '70s+', 'Focus on mobility, fall prevention, and managing chronic conditions proactively.'),
          ],
        ),
      ),
    );
  }

  Widget _buildDecadeCard(BuildContext context, String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text('In your $title'),
        subtitle: Text(description),
      ),
    );
  }
}
