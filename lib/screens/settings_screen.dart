import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import '../services/health_history_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _ageController  = TextEditingController();
  final _urlController  = TextEditingController();
  String _selectedGender = 'Prefer not to say';
  bool _profileEditing = false;

  static const List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<UserProfileService>();
      _nameController.text = profile.name;
      _ageController.text  = profile.age > 0 ? profile.age.toString() : '';
      _urlController.text  = profile.serverUrl;
      setState(() => _selectedGender = profile.gender);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final age  = int.tryParse(_ageController.text.trim()) ?? 0;
    if (name.isEmpty || age <= 0 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid name and age (1–120).'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    await context.read<UserProfileService>().updateProfile(
      name: name, age: age, gender: _selectedGender,
    );
    setState(() => _profileEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile saved. Hello, $name!'),
        backgroundColor: AppTheme.primaryColor,
      ));
    }
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await context.read<UserProfileService>().setServerUrl(url);
    if (mounted) FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Server URL updated.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final profile  = context.watch<UserProfileService>();
    final history  = context.watch<HealthHistoryService>();
    final cs       = Theme.of(context).colorScheme;
    final theme    = Theme.of(context);

    return Scaffold(

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Profile Banner ────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              children: [
                // Avatar + basic info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: cs.primary.withOpacity(0.15),
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name.isNotEmpty ? profile.name : 'Set your profile',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (profile.age > 0)
                            Text(
                              '${profile.age} yrs  ·  ${profile.gender}',
                              style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_profileEditing ? Icons.close : Icons.edit_outlined, color: cs.primary),
                      onPressed: () => setState(() => _profileEditing = !_profileEditing),
                    ),
                  ],
                ),

                // Editable fields (collapsible)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _profileEditing
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _ageController,
                              decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined), suffixText: 'years'),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)),
                              items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (v) => setState(() => _selectedGender = v ?? _selectedGender),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Profile'),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Appearance ────────────────────────────────────────────────────
          _SectionCard(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            child: Column(
              children: [
                _ThemeTile(
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                  selected: profile.themeMode == ThemeMode.light,
                  onTap: () => profile.setThemeMode(ThemeMode.light),
                ),
                _ThemeTile(
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  selected: profile.themeMode == ThemeMode.dark,
                  onTap: () => profile.setThemeMode(ThemeMode.dark),
                ),
                _ThemeTile(
                  label: 'System Default',
                  icon: Icons.brightness_auto_outlined,
                  selected: profile.themeMode == ThemeMode.system,
                  onTap: () => profile.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Server Config ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Backend Server URL',
            icon: Icons.cloud_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'https://healpro-api.onrender.com/api',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _saveUrl,
                  icon: const Icon(Icons.check_outlined),
                  label: const Text('Apply URL'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Health History ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Health History',
            icon: Icons.history_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (history.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No risk assessments saved yet.',
                        style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
                  )
                else ...[
                  Text(
                    '${history.entries.length} record(s) saved',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  // Recent 5 records
                  ...history.entries.reversed.take(5).map((e) => _HistoryTile(entry: e, history: history)),
                  if (history.entries.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('+${history.entries.length - 5} more records',
                          style: TextStyle(color: cs.onSurface.withOpacity(0.45), fontSize: 12)),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Clear History'),
                          content: const Text('This will delete all saved risk records. Are you sure?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Delete All'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await history.clearHistory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Clear All Records', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── About ─────────────────────────────────────────────────────────
          _SectionCard(
            title: 'About',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HealPRO AI Diagnostics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('An intelligent, cross-platform mobile diagnostic assistant powered by machine learning models trained on clinical datasets.'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Disclaimer ─────────────────────────────────────────────────────
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
                      const SizedBox(width: 8),
                      Text('Medical Disclaimer',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.error)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The risk scores provided by this app are for educational purposes only and do NOT constitute formal medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional.',
                    style: TextStyle(color: cs.onErrorContainer, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;

  const _SectionCard({required this.child, this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (icon != null) Icon(icon, size: 18, color: cs.primary),
                  if (icon != null) const SizedBox(width: 8),
                  Text(title!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.primary)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeTile({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: selected ? cs.primary : cs.onSurface.withOpacity(0.5), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? cs.primary : null,
              )),
            ),
            if (selected) Icon(Icons.check_circle, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final RiskEntry entry;
  final HealthHistoryService history;
  const _HistoryTile({required this.entry, required this.history});

  @override
  Widget build(BuildContext context) {
    final color = history.riskColor(entry.riskPercentage);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('${entry.type} — ${entry.riskPercentage.toStringAsFixed(1)}% (${history.riskLabel(entry.riskPercentage)})',
            style: const TextStyle(fontSize: 13))),
          Text(
            '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
