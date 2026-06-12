import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/health_history_service.dart';
import '../models/clinical_models.dart';

class ClinicalRisksScreen extends StatefulWidget {
  const ClinicalRisksScreen({super.key});

  @override
  State<ClinicalRisksScreen> createState() => _ClinicalRisksScreenState();
}

class _ClinicalRisksScreenState extends State<ClinicalRisksScreen> {
  // Loading and Error States
  bool _isDiabetesLoading = false, _isHeartLoading = false, _isKidneyLoading = false, _isThyroidLoading = false;
  String? _diabetesError, _heartError, _kidneyError, _thyroidError;

  // Prediction Results
  PredictResponse? _diabetesResult, _heartResult, _kidneyResult, _thyroidResult;

  // Diabetes form variables
  double _dPregnancies = 0, _dGlucose = 110, _dBloodPressure = 70, _dSkinThickness = 0, _dInsulin = 0, _dBmi = 24.5, _dPedigree = 0.47, _dAge = 30;

  // Heart form variables
  double _hAge = 55.0, _hSex = 1.0, _hCp = 3.0, _hTrestbps = 130.0, _hChol = 245.0, _hFbs = 0.0, _hRestecg = 2.0, _hThalach = 153.5, _hExang = 0.0, _hOldpeak = 0.8, _hSlope = 2.0, _hCa = 0.0, _hThal = 3.0;

  // Kidney form variables
  double _kAge = 55.0, _kBp = 80.0, _kBgr = 121.0, _kBu = 42.0, _kSc = 1.3, _kSod = 138.0, _kPot = 4.4, _kHemo = 12.6, _kPcv = 40.0, _kWc = 8000.0, _kRc = 4.8;
  String _kSg = '1.02', _kAl = '0', _kSu = '0', _kRbc = 'normal', _kPc = 'normal', _kPcc = 'notpresent', _kBa = 'notpresent', _kHtn = 'no', _kDm = 'no', _kCad = 'no', _kAppet = 'good', _kPe = 'no', _kAne = 'no';

  // Thyroid form variables
  double _tAge = 55.0, _tTsh = 1.4, _tT3 = 1.9, _tTt4 = 104.0, _tT4u = 0.96, _tFti = 109.0;
  String _tSex = 'f', _tOnThyroxine = 'f', _tQueryOnThyroxine = 'f', _tOnAntithyroidMeds = 'f', _tSick = 'f', _tPregnant = 'f', _tThyroidSurgery = 'f', _tI131Treatment = 'f', _tQueryHypothyroid = 'f', _tQueryHyperthyroid = 'f', _tLithium = 'f', _tGoitre = 'f', _tTumor = 'f', _tHypopituitary = 'f', _tPsych = 'f';

  // Form Keys
  final _diabetesFormKey = GlobalKey<FormState>();
  final _heartFormKey = GlobalKey<FormState>();
  final _kidneyFormKey = GlobalKey<FormState>();
  final _thyroidFormKey = GlobalKey<FormState>();

  void _calculateDiabetes() async {
    if (!_diabetesFormKey.currentState!.validate()) return;
    _diabetesFormKey.currentState!.save();
    
    setState(() {
      _isDiabetesLoading = true;
      _diabetesError = null;
      _diabetesResult = null;
    });

    final api = Provider.of<ApiService>(context, listen: false);
    final input = DiabetesInput(
      pregnancies: _dPregnancies, glucose: _dGlucose, bloodPressure: _dBloodPressure, 
      skinThickness: _dSkinThickness, insulin: _dInsulin, bmi: _dBmi, pedigree: _dPedigree, age: _dAge
    );
    try {
      final res = await api.predictDiabetes(input);
      setState(() {
        _diabetesResult = res;
        _isDiabetesLoading = false;
      });
      // Persist to history
      await Provider.of<HealthHistoryService>(context, listen: false).addEntry(
        RiskEntry(type: 'Diabetes', riskPercentage: res.riskPercentage, predictedClass: res.predictedClass, timestamp: DateTime.now()),
      );
    } catch(e) {
      setState(() {
        _diabetesError = e.toString().replaceFirst('Exception: ', '');
        _isDiabetesLoading = false;
      });
    }
  }

  void _calculateHeart() async {
    if (!_heartFormKey.currentState!.validate()) return;
    _heartFormKey.currentState!.save();

    setState(() {
      _isHeartLoading = true;
      _heartError = null;
      _heartResult = null;
    });

    final api = Provider.of<ApiService>(context, listen: false);
    final input = HeartInput(
      age: _hAge, sex: _hSex, cp: _hCp, trestbps: _hTrestbps, chol: _hChol, fbs: _hFbs, 
      restecg: _hRestecg, thalach: _hThalach, exang: _hExang, oldpeak: _hOldpeak, slope: _hSlope, ca: _hCa, thal: _hThal
    );
    try {
      final res = await api.predictHeart(input);
      setState(() {
        _heartResult = res;
        _isHeartLoading = false;
      });
      await Provider.of<HealthHistoryService>(context, listen: false).addEntry(
        RiskEntry(type: 'Heart', riskPercentage: res.riskPercentage, predictedClass: res.predictedClass, timestamp: DateTime.now()),
      );
    } catch(e) {
      setState(() {
        _heartError = e.toString().replaceFirst('Exception: ', '');
        _isHeartLoading = false;
      });
    }
  }

  void _calculateKidney() async {
    if (!_kidneyFormKey.currentState!.validate()) return;
    _kidneyFormKey.currentState!.save();

    setState(() {
      _isKidneyLoading = true;
      _kidneyError = null;
      _kidneyResult = null;
    });

    final api = Provider.of<ApiService>(context, listen: false);
    final input = KidneyInput(
      age: _kAge, bp: _kBp, sg: _kSg, al: _kAl, su: _kSu, rbc: _kRbc, pc: _kPc, pcc: _kPcc, ba: _kBa, 
      bgr: _kBgr, bu: _kBu, sc: _kSc, sod: _kSod, pot: _kPot, hemo: _kHemo, pcv: _kPcv, wc: _kWc, rc: _kRc, 
      htn: _kHtn, dm: _kDm, cad: _kCad, appet: _kAppet, pe: _kPe, ane: _kAne
    );
    try {
      final res = await api.predictKidney(input);
      setState(() {
        _kidneyResult = res;
        _isKidneyLoading = false;
      });
      await Provider.of<HealthHistoryService>(context, listen: false).addEntry(
        RiskEntry(type: 'Kidney', riskPercentage: res.riskPercentage, predictedClass: res.predictedClass, timestamp: DateTime.now()),
      );
    } catch(e) {
      setState(() {
        _kidneyError = e.toString().replaceFirst('Exception: ', '');
        _isKidneyLoading = false;
      });
    }
  }

  void _calculateThyroid() async {
    if (!_thyroidFormKey.currentState!.validate()) return;
    _thyroidFormKey.currentState!.save();

    setState(() {
      _isThyroidLoading = true;
      _thyroidError = null;
      _thyroidResult = null;
    });

    final api = Provider.of<ApiService>(context, listen: false);
    final input = ThyroidInput(
      age: _tAge, sex: _tSex, onThyroxine: _tOnThyroxine, queryOnThyroxine: _tQueryOnThyroxine, 
      onAntithyroidMeds: _tOnAntithyroidMeds, sick: _tSick, pregnant: _tPregnant, thyroidSurgery: _tThyroidSurgery, 
      i131Treatment: _tI131Treatment, queryHypothyroid: _tQueryHypothyroid, queryHyperthyroid: _tQueryHyperthyroid, 
      lithium: _tLithium, goitre: _tGoitre, tumor: _tTumor, hypopituitary: _tHypopituitary, psych: _tPsych, 
      tsh: _tTsh, t3: _tT3, tt4: _tTt4, t4u: _tT4u, fti: _tFti
    );
    try {
      final res = await api.predictThyroid(input);
      setState(() {
        _thyroidResult = res;
        _isThyroidLoading = false;
      });
      await Provider.of<HealthHistoryService>(context, listen: false).addEntry(
        RiskEntry(type: 'Thyroid', riskPercentage: res.riskPercentage, predictedClass: res.predictedClass, timestamp: DateTime.now()),
      );
    } catch(e) {
      setState(() {
        _thyroidError = e.toString().replaceFirst('Exception: ', '');
        _isThyroidLoading = false;
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo[900])),
          const Divider(height: 8, thickness: 1.2),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildResultDisplay(String label, PredictResponse? response, String? errorMessage) {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text('Error predicting: $errorMessage', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
          ],
        ),
      );
    }
    if (response == null) return const SizedBox.shrink();

    final pct = response.riskPercentage;
    Color levelColor = Colors.green;
    String status = 'Low Risk';
    if (pct > 50.0) {
      levelColor = Colors.red;
      status = 'High Risk';
    } else if (pct > 20.0) {
      levelColor = Colors.orange;
      status = 'Moderate Risk';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('$label Risk Assessment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: pct / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: levelColor)),
                    const SizedBox(height: 1),
                    Text(status, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pct > 50.0 
                ? 'Prediction suggests an elevated probability. Please seek professional medical evaluation.'
                : pct > 20.0
                ? 'Moderate risk detected. Regular checks and healthy lifestyle habits are recommended.'
                : 'Probability is low. Maintain healthy habits and perform routine screenings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Diabetes'),
                Tab(text: 'Heart'),
                Tab(text: 'Kidney'),
                Tab(text: 'Thyroid'),
              ],
            ),
            Expanded(
              child: TabBarView(
          children: [
            // Diabetes Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _diabetesFormKey,
                child: ListView(
                  children: [
                    const Text('Assess your Type-2 Diabetes risk probability.'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Age',
                      initialValue: _dAge.toString(),
                      onSaved: (val) => _dAge = double.tryParse(val!) ?? _dAge,
                      suffixText: 'years',
                    ),
                    _buildTextField(
                      label: 'Glucose Level',
                      initialValue: _dGlucose.toString(),
                      onSaved: (val) => _dGlucose = double.tryParse(val!) ?? _dGlucose,
                      suffixText: 'mg/dL',
                    ),
                    _buildTextField(
                      label: 'BMI',
                      initialValue: _dBmi.toString(),
                      onSaved: (val) => _dBmi = double.tryParse(val!) ?? _dBmi,
                      suffixText: 'kg/m²',
                    ),
                    _buildTextField(
                      label: 'Pregnancies',
                      initialValue: _dPregnancies.toString(),
                      onSaved: (val) => _dPregnancies = double.tryParse(val!) ?? _dPregnancies,
                    ),
                    _buildTextField(
                      label: 'Blood Pressure',
                      initialValue: _dBloodPressure.toString(),
                      onSaved: (val) => _dBloodPressure = double.tryParse(val!) ?? _dBloodPressure,
                      suffixText: 'mmHg',
                    ),
                    _buildTextField(
                      label: 'Skin Thickness',
                      initialValue: _dSkinThickness.toString(),
                      onSaved: (val) => _dSkinThickness = double.tryParse(val!) ?? _dSkinThickness,
                      suffixText: 'mm',
                    ),
                    _buildTextField(
                      label: 'Insulin',
                      initialValue: _dInsulin.toString(),
                      onSaved: (val) => _dInsulin = double.tryParse(val!) ?? _dInsulin,
                      suffixText: 'mu U/ml',
                    ),
                    _buildTextField(
                      label: 'Diabetes Pedigree Function',
                      initialValue: _dPedigree.toString(),
                      onSaved: (val) => _dPedigree = double.tryParse(val!) ?? _dPedigree,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isDiabetesLoading ? null : _calculateDiabetes,
                      child: _isDiabetesLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Calculate Diabetes Risk'),
                    ),
                    _buildResultDisplay('Diabetes', _diabetesResult, _diabetesError),
                  ],
                ),
              ),
            ),

            // Heart Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _heartFormKey,
                child: ListView(
                  children: [
                    const Text('Assess your Heart Disease risk probability.'),
                    const SizedBox(height: 12),
                    _buildSectionHeader('Demographics & Vitals'),
                    _buildTextField(
                      label: 'Age',
                      initialValue: _hAge.toString(),
                      onSaved: (val) => _hAge = double.tryParse(val!) ?? _hAge,
                      suffixText: 'years',
                    ),
                    _buildDropdownField<double>(
                      label: 'Sex',
                      value: _hSex,
                      items: const [
                        DropdownMenuItem(value: 1.0, child: Text('Male')),
                        DropdownMenuItem(value: 0.0, child: Text('Female')),
                      ],
                      onChanged: (val) => setState(() => _hSex = val ?? _hSex),
                    ),
                    _buildTextField(
                      label: 'Resting Blood Pressure',
                      initialValue: _hTrestbps.toString(),
                      onSaved: (val) => _hTrestbps = double.tryParse(val!) ?? _hTrestbps,
                      suffixText: 'mmHg',
                    ),
                    _buildTextField(
                      label: 'Cholesterol',
                      initialValue: _hChol.toString(),
                      onSaved: (val) => _hChol = double.tryParse(val!) ?? _hChol,
                      suffixText: 'mg/dL',
                    ),
                    
                    _buildSectionHeader('Electrocardiogram & Vitals'),
                    _buildTextField(
                      label: 'Max Heart Rate Achieved',
                      initialValue: _hThalach.toString(),
                      onSaved: (val) => _hThalach = double.tryParse(val!) ?? _hThalach,
                      suffixText: 'bpm',
                    ),
                    _buildTextField(
                      label: 'ST Depression (Oldpeak)',
                      initialValue: _hOldpeak.toString(),
                      onSaved: (val) => _hOldpeak = double.tryParse(val!) ?? _hOldpeak,
                    ),
                    _buildDropdownField<double>(
                      label: 'Resting ECG',
                      value: _hRestecg,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('Normal')),
                        DropdownMenuItem(value: 1.0, child: Text('ST-T Wave Abnormality')),
                        DropdownMenuItem(value: 2.0, child: Text('Left Ventricular Hypertrophy')),
                      ],
                      onChanged: (val) => setState(() => _hRestecg = val ?? _hRestecg),
                    ),
                    _buildDropdownField<double>(
                      label: 'Peak Exercise ST Slope',
                      value: _hSlope,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('Upsloping')),
                        DropdownMenuItem(value: 1.0, child: Text('Flat')),
                        DropdownMenuItem(value: 2.0, child: Text('Downsloping')),
                      ],
                      onChanged: (val) => setState(() => _hSlope = val ?? _hSlope),
                    ),
                    
                    _buildSectionHeader('Clinical History & Symptoms'),
                    _buildDropdownField<double>(
                      label: 'Chest Pain Type',
                      value: _hCp,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('Typical Angina')),
                        DropdownMenuItem(value: 1.0, child: Text('Atypical Angina')),
                        DropdownMenuItem(value: 2.0, child: Text('Non-anginal Pain')),
                        DropdownMenuItem(value: 3.0, child: Text('Asymptomatic')),
                      ],
                      onChanged: (val) => setState(() => _hCp = val ?? _hCp),
                    ),
                    _buildDropdownField<double>(
                      label: 'Fasting Blood Sugar > 120 mg/dL',
                      value: _hFbs,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('False')),
                        DropdownMenuItem(value: 1.0, child: Text('True')),
                      ],
                      onChanged: (val) => setState(() => _hFbs = val ?? _hFbs),
                    ),
                    _buildDropdownField<double>(
                      label: 'Exercise Induced Angina',
                      value: _hExang,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('No')),
                        DropdownMenuItem(value: 1.0, child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _hExang = val ?? _hExang),
                    ),
                    _buildDropdownField<double>(
                      label: 'Number of Major Vessels Coloured by Fluoroscopy',
                      value: _hCa,
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('0')),
                        DropdownMenuItem(value: 1.0, child: Text('1')),
                        DropdownMenuItem(value: 2.0, child: Text('2')),
                        DropdownMenuItem(value: 3.0, child: Text('3')),
                        DropdownMenuItem(value: 4.0, child: Text('4')),
                      ],
                      onChanged: (val) => setState(() => _hCa = val ?? _hCa),
                    ),
                    _buildDropdownField<double>(
                      label: 'Thal (Thalassemia blood disorder)',
                      value: _hThal,
                      items: const [
                        DropdownMenuItem(value: 3.0, child: Text('Normal (3.0)')),
                        DropdownMenuItem(value: 6.0, child: Text('Fixed Defect (6.0)')),
                        DropdownMenuItem(value: 7.0, child: Text('Reversible Defect (7.0)')),
                      ],
                      onChanged: (val) => setState(() => _hThal = val ?? _hThal),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isHeartLoading ? null : _calculateHeart,
                      child: _isHeartLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Calculate Heart Risk'),
                    ),
                    _buildResultDisplay('Heart', _heartResult, _heartError),
                  ],
                ),
              ),
            ),

            // Kidney Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _kidneyFormKey,
                child: ListView(
                  children: [
                    const Text('Assess your Chronic Kidney Disease risk probability.'),
                    const SizedBox(height: 12),
                    _buildSectionHeader('Lab & Vital Vitals'),
                    _buildTextField(
                      label: 'Age',
                      initialValue: _kAge.toString(),
                      onSaved: (val) => _kAge = double.tryParse(val!) ?? _kAge,
                      suffixText: 'years',
                    ),
                    _buildTextField(
                      label: 'Blood Pressure',
                      initialValue: _kBp.toString(),
                      onSaved: (val) => _kBp = double.tryParse(val!) ?? _kBp,
                      suffixText: 'mmHg',
                    ),
                    _buildTextField(
                      label: 'Blood Glucose Random',
                      initialValue: _kBgr.toString(),
                      onSaved: (val) => _kBgr = double.tryParse(val!) ?? _kBgr,
                      suffixText: 'mg/dL',
                    ),
                    _buildTextField(
                      label: 'Blood Urea',
                      initialValue: _kBu.toString(),
                      onSaved: (val) => _kBu = double.tryParse(val!) ?? _kBu,
                      suffixText: 'mEq/L',
                    ),
                    _buildTextField(
                      label: 'Serum Creatinine',
                      initialValue: _kSc.toString(),
                      onSaved: (val) => _kSc = double.tryParse(val!) ?? _kSc,
                      suffixText: 'mg/dL',
                    ),
                    _buildTextField(
                      label: 'Sodium',
                      initialValue: _kSod.toString(),
                      onSaved: (val) => _kSod = double.tryParse(val!) ?? _kSod,
                      suffixText: 'mEq/L',
                    ),
                    _buildTextField(
                      label: 'Potassium',
                      initialValue: _kPot.toString(),
                      onSaved: (val) => _kPot = double.tryParse(val!) ?? _kPot,
                      suffixText: 'mEq/L',
                    ),
                    _buildTextField(
                      label: 'Hemoglobin',
                      initialValue: _kHemo.toString(),
                      onSaved: (val) => _kHemo = double.tryParse(val!) ?? _kHemo,
                      suffixText: 'g/dL',
                    ),
                    _buildTextField(
                      label: 'Packed Cell Volume',
                      initialValue: _kPcv.toString(),
                      onSaved: (val) => _kPcv = double.tryParse(val!) ?? _kPcv,
                    ),
                    _buildTextField(
                      label: 'White Blood Cell Count',
                      initialValue: _kWc.toString(),
                      onSaved: (val) => _kWc = double.tryParse(val!) ?? _kWc,
                      suffixText: 'cells/cumm',
                    ),
                    _buildTextField(
                      label: 'Red Blood Cell Count',
                      initialValue: _kRc.toString(),
                      onSaved: (val) => _kRc = double.tryParse(val!) ?? _kRc,
                      suffixText: 'millions/cmm',
                    ),
                    
                    _buildSectionHeader('Urine Lab Findings'),
                    _buildDropdownField<String>(
                      label: 'Specific Gravity',
                      value: _kSg,
                      items: const [
                        DropdownMenuItem(value: '1.005', child: Text('1.005')),
                        DropdownMenuItem(value: '1.010', child: Text('1.010')),
                        DropdownMenuItem(value: '1.015', child: Text('1.015')),
                        DropdownMenuItem(value: '1.020', child: Text('1.020')),
                        DropdownMenuItem(value: '1.025', child: Text('1.025')),
                      ],
                      onChanged: (val) => setState(() => _kSg = val ?? _kSg),
                    ),
                    _buildDropdownField<String>(
                      label: 'Albumin Level',
                      value: _kAl,
                      items: const [
                        DropdownMenuItem(value: '0', child: Text('0 (None)')),
                        DropdownMenuItem(value: '1', child: Text('1')),
                        DropdownMenuItem(value: '2', child: Text('2')),
                        DropdownMenuItem(value: '3', child: Text('3')),
                        DropdownMenuItem(value: '4', child: Text('4')),
                        DropdownMenuItem(value: '5', child: Text('5')),
                      ],
                      onChanged: (val) => setState(() => _kAl = val ?? _kAl),
                    ),
                    _buildDropdownField<String>(
                      label: 'Sugar Level',
                      value: _kSu,
                      items: const [
                        DropdownMenuItem(value: '0', child: Text('0 (None)')),
                        DropdownMenuItem(value: '1', child: Text('1')),
                        DropdownMenuItem(value: '2', child: Text('2')),
                        DropdownMenuItem(value: '3', child: Text('3')),
                        DropdownMenuItem(value: '4', child: Text('4')),
                        DropdownMenuItem(value: '5', child: Text('5')),
                      ],
                      onChanged: (val) => setState(() => _kSu = val ?? _kSu),
                    ),
                    _buildDropdownField<String>(
                      label: 'Red Blood Cells in Urine',
                      value: _kRbc,
                      items: const [
                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                        DropdownMenuItem(value: 'abnormal', child: Text('Abnormal')),
                      ],
                      onChanged: (val) => setState(() => _kRbc = val ?? _kRbc),
                    ),
                    _buildDropdownField<String>(
                      label: 'Pus Cells in Urine',
                      value: _kPc,
                      items: const [
                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                        DropdownMenuItem(value: 'abnormal', child: Text('Abnormal')),
                      ],
                      onChanged: (val) => setState(() => _kPc = val ?? _kPc),
                    ),
                    _buildDropdownField<String>(
                      label: 'Pus Cell Clumps',
                      value: _kPcc,
                      items: const [
                        DropdownMenuItem(value: 'notpresent', child: Text('Not Present')),
                        DropdownMenuItem(value: 'present', child: Text('Present')),
                      ],
                      onChanged: (val) => setState(() => _kPcc = val ?? _kPcc),
                    ),
                    _buildDropdownField<String>(
                      label: 'Bacteria in Urine',
                      value: _kBa,
                      items: const [
                        DropdownMenuItem(value: 'notpresent', child: Text('Not Present')),
                        DropdownMenuItem(value: 'present', child: Text('Present')),
                      ],
                      onChanged: (val) => setState(() => _kBa = val ?? _kBa),
                    ),
                    
                    _buildSectionHeader('Medical History & Symptoms'),
                    _buildDropdownField<String>(
                      label: 'Hypertension',
                      value: _kHtn,
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No')),
                        DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _kHtn = val ?? _kHtn),
                    ),
                    _buildDropdownField<String>(
                      label: 'Diabetes Mellitus',
                      value: _kDm,
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No')),
                        DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _kDm = val ?? _kDm),
                    ),
                    _buildDropdownField<String>(
                      label: 'Coronary Artery Disease',
                      value: _kCad,
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No')),
                        DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _kCad = val ?? _kCad),
                    ),
                    _buildDropdownField<String>(
                      label: 'Appetite',
                      value: _kAppet,
                      items: const [
                        DropdownMenuItem(value: 'good', child: Text('Good')),
                        DropdownMenuItem(value: 'poor', child: Text('Poor')),
                      ],
                      onChanged: (val) => setState(() => _kAppet = val ?? _kAppet),
                    ),
                    _buildDropdownField<String>(
                      label: 'Pedal Edema',
                      value: _kPe,
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No')),
                        DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _kPe = val ?? _kPe),
                    ),
                    _buildDropdownField<String>(
                      label: 'Anemia',
                      value: _kAne,
                      items: const [
                        DropdownMenuItem(value: 'no', child: Text('No')),
                        DropdownMenuItem(value: 'yes', child: Text('Yes')),
                      ],
                      onChanged: (val) => setState(() => _kAne = val ?? _kAne),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isKidneyLoading ? null : _calculateKidney,
                      child: _isKidneyLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Calculate Kidney Risk'),
                    ),
                    _buildResultDisplay('Chronic Kidney', _kidneyResult, _kidneyError),
                  ],
                ),
              ),
            ),

            // Thyroid Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _thyroidFormKey,
                child: ListView(
                  children: [
                    const Text('Assess your Thyroid Disease risk probability.'),
                    const SizedBox(height: 12),
                    _buildSectionHeader('Lab Findings & Demographics'),
                    _buildTextField(
                      label: 'Age',
                      initialValue: _tAge.toString(),
                      onSaved: (val) => _tAge = double.tryParse(val!) ?? _tAge,
                      suffixText: 'years',
                    ),
                    _buildDropdownField<String>(
                      label: 'Sex',
                      value: _tSex,
                      items: const [
                        DropdownMenuItem(value: 'm', child: Text('Male')),
                        DropdownMenuItem(value: 'f', child: Text('Female')),
                      ],
                      onChanged: (val) => setState(() => _tSex = val ?? _tSex),
                    ),
                    _buildTextField(
                      label: 'TSH Level',
                      initialValue: _tTsh.toString(),
                      onSaved: (val) => _tTsh = double.tryParse(val!) ?? _tTsh,
                      suffixText: 'µIU/mL',
                    ),
                    _buildTextField(
                      label: 'T3 Level',
                      initialValue: _tT3.toString(),
                      onSaved: (val) => _tT3 = double.tryParse(val!) ?? _tT3,
                      suffixText: 'ng/dL',
                    ),
                    _buildTextField(
                      label: 'TT4 Level',
                      initialValue: _tTt4.toString(),
                      onSaved: (val) => _tTt4 = double.tryParse(val!) ?? _tTt4,
                      suffixText: 'µg/dL',
                    ),
                    _buildTextField(
                      label: 'T4U Level',
                      initialValue: _tT4u.toString(),
                      onSaved: (val) => _tT4u = double.tryParse(val!) ?? _tT4u,
                    ),
                    _buildTextField(
                      label: 'FTI Level',
                      initialValue: _tFti.toString(),
                      onSaved: (val) => _tFti = double.tryParse(val!) ?? _tFti,
                    ),
                    
                    _buildSectionHeader('Clinical History Flags'),
                    _buildSwitchTile(
                      label: 'On Thyroxine treatment',
                      value: _tOnThyroxine == 't',
                      onChanged: (val) => setState(() => _tOnThyroxine = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Query on Thyroxine',
                      value: _tQueryOnThyroxine == 't',
                      onChanged: (val) => setState(() => _tQueryOnThyroxine = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'On Antithyroid medication',
                      value: _tOnAntithyroidMeds == 't',
                      onChanged: (val) => setState(() => _tOnAntithyroidMeds = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Clinically sick',
                      value: _tSick == 't',
                      onChanged: (val) => setState(() => _tSick = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Pregnant',
                      value: _tPregnant == 't',
                      onChanged: (val) => setState(() => _tPregnant = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'History of Thyroid Surgery',
                      value: _tThyroidSurgery == 't',
                      onChanged: (val) => setState(() => _tThyroidSurgery = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'History of I131 treatment',
                      value: _tI131Treatment == 't',
                      onChanged: (val) => setState(() => _tI131Treatment = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Query Hypothyroid',
                      value: _tQueryHypothyroid == 't',
                      onChanged: (val) => setState(() => _tQueryHypothyroid = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Query Hyperthyroid',
                      value: _tQueryHyperthyroid == 't',
                      onChanged: (val) => setState(() => _tQueryHyperthyroid = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Lithium treatment',
                      value: _tLithium == 't',
                      onChanged: (val) => setState(() => _tLithium = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Goitre present',
                      value: _tGoitre == 't',
                      onChanged: (val) => setState(() => _tGoitre = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Tumor present',
                      value: _tTumor == 't',
                      onChanged: (val) => setState(() => _tTumor = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Hypopituitary present',
                      value: _tHypopituitary == 't',
                      onChanged: (val) => setState(() => _tHypopituitary = val ? 't' : 'f'),
                    ),
                    _buildSwitchTile(
                      label: 'Psychiatric symptoms',
                      value: _tPsych == 't',
                      onChanged: (val) => setState(() => _tPsych = val ? 't' : 'f'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isThyroidLoading ? null : _calculateThyroid,
                      child: _isThyroidLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Calculate Thyroid Risk'),
                    ),
                    _buildResultDisplay('Thyroid', _thyroidResult, _thyroidError),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        ],
        ),
      ),
    );
  }
}
