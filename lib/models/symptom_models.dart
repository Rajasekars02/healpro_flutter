class SymptomRequest {
  final List<String> symptoms;

  SymptomRequest({required this.symptoms});

  Map<String, dynamic> toJson() => {
    'symptoms': symptoms,
  };
}

class DiagnosticMatch {
  final String disease;
  final double score;
  final List<String> matchedSymptoms;
  final String cures;
  final String doctor;
  final String riskLevel;

  DiagnosticMatch({
    required this.disease,
    required this.score,
    required this.matchedSymptoms,
    required this.cures,
    required this.doctor,
    required this.riskLevel,
  });

  factory DiagnosticMatch.fromJson(Map<String, dynamic> json) {
    return DiagnosticMatch(
      disease: json['disease'] ?? 'Unknown',
      score: (json['score'] ?? 0.0).toDouble(),
      matchedSymptoms: List<String>.from(json['matched_symptoms'] ?? json['symptoms'] ?? []),
      cures: json['cures'] ?? '',
      doctor: json['doctor'] ?? '',
      riskLevel: json['risk_level'] ?? 'Unknown',
    );
  }
}

class DiagnoseInitiateResponse {
  final List<DiagnosticMatch> matchingDiseases;
  final List<String> questions;

  DiagnoseInitiateResponse({
    required this.matchingDiseases,
    required this.questions,
  });

  factory DiagnoseInitiateResponse.fromJson(Map<String, dynamic> json) {
    return DiagnoseInitiateResponse(
      matchingDiseases: (json['matching_diseases'] as List)
          .map((e) => DiagnosticMatch.fromJson(e))
          .toList(),
      questions: List<String>.from(json['questions'] ?? []),
    );
  }
}
