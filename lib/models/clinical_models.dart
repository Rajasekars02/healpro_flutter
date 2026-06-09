class PredictResponse {
  final double riskPercentage;
  final int predictedClass;

  PredictResponse({required this.riskPercentage, required this.predictedClass});

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    return PredictResponse(
      riskPercentage: (json['risk_percentage'] ?? 0.0).toDouble(),
      predictedClass: json['class'] ?? 0,
    );
  }
}

class DiabetesInput {
  final double pregnancies;
  final double glucose;
  final double bloodPressure;
  final double skinThickness;
  final double insulin;
  final double bmi;
  final double pedigree;
  final double age;

  DiabetesInput({
    required this.pregnancies, required this.glucose, required this.bloodPressure,
    required this.skinThickness, required this.insulin, required this.bmi,
    required this.pedigree, required this.age,
  });

  Map<String, dynamic> toJson() => {
    'pregnancies': pregnancies, 'glucose': glucose, 'bloodPressure': bloodPressure,
    'skinThickness': skinThickness, 'insulin': insulin, 'bmi': bmi,
    'pedigree': pedigree, 'age': age,
  };
}

class HeartInput {
  final double age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak, slope, ca, thal;

  HeartInput({
    required this.age, required this.sex, required this.cp, required this.trestbps,
    required this.chol, required this.fbs, required this.restecg, required this.thalach,
    required this.exang, required this.oldpeak, required this.slope, required this.ca, required this.thal,
  });

  Map<String, dynamic> toJson() => {
    'age': age, 'sex': sex, 'cp': cp, 'trestbps': trestbps, 'chol': chol, 'fbs': fbs,
    'restecg': restecg, 'thalach': thalach, 'exang': exang, 'oldpeak': oldpeak,
    'slope': slope, 'ca': ca, 'thal': thal,
  };
}

class KidneyInput {
  final double age, bp, bgr, bu, sc, sod, pot, hemo, pcv, wc, rc;
  final String sg, al, su, rbc, pc, pcc, ba, htn, dm, cad, appet, pe, ane;

  KidneyInput({
    required this.age, required this.bp, required this.sg, required this.al, required this.su,
    required this.rbc, required this.pc, required this.pcc, required this.ba,
    required this.bgr, required this.bu, required this.sc, required this.sod, required this.pot,
    required this.hemo, required this.pcv, required this.wc, required this.rc,
    required this.htn, required this.dm, required this.cad, required this.appet,
    required this.pe, required this.ane,
  });

  Map<String, dynamic> toJson() => {
    'age': age, 'bp': bp, 'sg': double.tryParse(sg) ?? 1.020, 'al': double.tryParse(al) ?? 0, 'su': double.tryParse(su) ?? 0,
    'rbc': rbc, 'pc': pc, 'pcc': pcc, 'ba': ba, 'bgr': bgr, 'bu': bu, 'sc': sc, 'sod': sod, 'pot': pot,
    'hemo': hemo, 'pcv': pcv, 'wc': wc, 'rc': rc, 'htn': htn, 'dm': dm, 'cad': cad, 'appet': appet,
    'pe': pe, 'ane': ane,
  };
}

class ThyroidInput {
  final double age, tsh, t3, tt4, t4u, fti;
  final String sex, onThyroxine, queryOnThyroxine, onAntithyroidMeds, sick, pregnant, thyroidSurgery;
  final String i131Treatment, queryHypothyroid, queryHyperthyroid, lithium, goitre, tumor, hypopituitary, psych;

  ThyroidInput({
    required this.age, required this.sex, required this.onThyroxine, required this.queryOnThyroxine,
    required this.onAntithyroidMeds, required this.sick, required this.pregnant, required this.thyroidSurgery,
    required this.i131Treatment, required this.queryHypothyroid, required this.queryHyperthyroid,
    required this.lithium, required this.goitre, required this.tumor, required this.hypopituitary,
    required this.psych, required this.tsh, required this.t3, required this.tt4, required this.t4u, required this.fti,
  });

  Map<String, dynamic> toJson() => {
    'age': age, 'sex': sex, 'on_thyroxine': onThyroxine, 'query_on_thyroxine': queryOnThyroxine,
    'on_antithyroid_meds': onAntithyroidMeds, 'sick': sick, 'pregnant': pregnant, 'thyroid_surgery': thyroidSurgery,
    'I131_treatment': i131Treatment, 'query_hypothyroid': queryHypothyroid, 'query_hyperthyroid': queryHyperthyroid,
    'lithium': lithium, 'goitre': goitre, 'tumor': tumor, 'hypopituitary': hypopituitary, 'psych': psych,
    'TSH': tsh, 'T3': t3, 'TT4': tt4, 'T4U': t4u, 'FTI': fti,
  };
}
