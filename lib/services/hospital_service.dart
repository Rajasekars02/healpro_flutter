import 'package:flutter/foundation.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final double distanceInKm;
  final double rating;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceInKm,
    required this.rating,
  });
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospitalId;
  final double rating;
  final String availability;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospitalId,
    required this.rating,
    required this.availability,
  });
}

class HospitalService {
  // Mock data for hospitals
  final List<Hospital> _mockHospitals = [
    Hospital(id: 'h1', name: 'City General Hospital', address: '123 Main St, Cityville', distanceInKm: 1.2, rating: 4.5),
    Hospital(id: 'h2', name: 'Mercy Medical Center', address: '456 Oak Ave, Cityville', distanceInKm: 3.5, rating: 4.8),
    Hospital(id: 'h3', name: 'St. Jude Community Hospital', address: '789 Pine Blvd, Cityville', distanceInKm: 5.0, rating: 4.2),
  ];

  // Mock data for doctors
  final List<Doctor> _mockDoctors = [
    Doctor(id: 'd1', name: 'Dr. Alice Smith', specialization: 'General Physician', hospitalId: 'h1', rating: 4.7, availability: 'Available Now'),
    Doctor(id: 'd2', name: 'Dr. Bob Johnson', specialization: 'Cardiologist', hospitalId: 'h1', rating: 4.9, availability: 'Available at 2:00 PM'),
    Doctor(id: 'd3', name: 'Dr. Carol Williams', specialization: 'Surgeon', hospitalId: 'h2', rating: 4.6, availability: 'Available Now'),
    Doctor(id: 'd4', name: 'Dr. David Brown', specialization: 'Neurologist', hospitalId: 'h2', rating: 4.8, availability: 'Available Tomorrow'),
    Doctor(id: 'd5', name: 'Dr. Eve Davis', specialization: 'Surgeon', hospitalId: 'h3', rating: 4.5, availability: 'Available at 4:00 PM'),
  ];

  Future<List<Hospital>> getNearbyHospitals(double lat, double lng) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockHospitals;
  }

  Future<List<Doctor>> getDoctorsByHospital(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDoctors.where((doc) => doc.hospitalId == hospitalId).toList();
  }

  Future<List<Doctor>> getNearbyDoctorsBySpecialization(double lat, double lng, String specialization) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockDoctors.where((doc) => doc.specialization.toLowerCase() == specialization.toLowerCase()).toList();
  }
}
