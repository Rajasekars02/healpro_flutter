import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import 'symptom_ai_screen.dart';
import 'clinical_risks_screen.dart';
import 'age_insights_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.medical_information_outlined, activeIcon: Icons.medical_information, label: 'Symptom AI'),
    _NavItem(icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart, label: 'Risk Check'),
    _NavItem(icon: Icons.timeline_outlined, activeIcon: Icons.timeline, label: 'Age Guide'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  final List<Widget> _screens = [
    const SymptomAIScreen(),
    const ClinicalRisksScreen(),
    const AgeInsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileService>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withOpacity(0.15),
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon),
          label: item.label,
        )).toList(),
        animationDuration: const Duration(milliseconds: 300),
        height: 66,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
