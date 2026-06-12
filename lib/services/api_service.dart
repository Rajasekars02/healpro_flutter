import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom_models.dart';
import '../models/clinical_models.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'https://healpro-api.onrender.com/api'});

  Future<List<String>> getSymptoms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/symptoms'));
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
      throw Exception('Failed to load symptoms');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<DiagnoseInitiateResponse> initiateDiagnose(SymptomRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/diagnose/initiate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        return DiagnoseInitiateResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to initiate diagnose');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<DiagnosticMatch> finalDiagnose(SymptomRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/diagnose/final'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        return DiagnosticMatch.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to fetch final diagnosis');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PredictResponse> predictDiabetes(DiabetesInput input) async {
    return _predict('/predict/diabetes', input.toJson());
  }

  Future<PredictResponse> predictHeart(HeartInput input) async {
    return _predict('/predict/heart', input.toJson());
  }

  Future<PredictResponse> predictKidney(KidneyInput input) async {
    return _predict('/predict/kidney', input.toJson());
  }

  Future<PredictResponse> predictThyroid(ThyroidInput input) async {
    return _predict('/predict/thyroid', input.toJson());
  }

  Future<PredictResponse> _predict(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return PredictResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get prediction: HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
