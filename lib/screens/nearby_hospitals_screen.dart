import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/hospital_service.dart';
import '../services/location_service.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  final String? specializationFilter;

  const NearbyHospitalsScreen({super.key, this.specializationFilter});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  final HospitalService _hospitalService = HospitalService();
  final LocationService _locationService = LocationService();
  
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;
  List<Hospital> _hospitals = [];
  List<Doctor> _specializedDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentPosition = await _locationService.getCurrentLocation();
      
      if (_currentPosition != null) {
        if (widget.specializationFilter != null) {
           _specializedDoctors = await _hospitalService.getNearbyDoctorsBySpecialization(
             _currentPosition!.latitude, 
             _currentPosition!.longitude, 
             widget.specializationFilter!
           );
           
           // Fetch all hospitals to map doctor to hospital name
           _hospitals = await _hospitalService.getNearbyHospitals(
             _currentPosition!.latitude, 
             _currentPosition!.longitude
           );
        } else {
           _hospitals = await _hospitalService.getNearbyHospitals(
             _currentPosition!.latitude, 
             _currentPosition!.longitude
           );
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specializationFilter != null 
          ? 'Nearby ${widget.specializationFilter}s' 
          : 'Nearby Hospitals'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Locating nearby facilities...')
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Could not get location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              )
            ],
          ),
        ),
      );
    }

    if (widget.specializationFilter != null) {
      return _buildDoctorsList();
    } else {
      return _buildHospitalsList();
    }
  }

  Widget _buildDoctorsList() {
    if (_specializedDoctors.isEmpty) {
      return Center(
        child: Text('No ${widget.specializationFilter}s found nearby.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _specializedDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _specializedDoctors[index];
        final hospital = _hospitals.firstWhere((h) => h.id == doctor.hospitalId, 
          orElse: () => Hospital(id: '', name: 'Unknown Hospital', address: '', distanceInKm: 0, rating: 0));

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.specialization),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_hospital, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(hospital.name, style: const TextStyle(color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${doctor.rating}'),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.availability,
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${hospital.distanceInKm} km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildHospitalsList() {
    if (_hospitals.isEmpty) {
      return const Center(
        child: Text('No hospitals found nearby.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _hospitals.length,
      itemBuilder: (context, index) {
        final hospital = _hospitals[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.local_hospital, color: Colors.red),
            ),
            title: Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${hospital.rating}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${hospital.distanceInKm} km'),
                  ],
                ),
              ],
            ),
            children: [
              FutureBuilder<List<Doctor>>(
                future: _hospitalService.getDoctorsByHospital(hospital.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final doctors = snapshot.data ?? [];
                  
                  if (doctors.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No doctors available.'),
                    );
                  }

                  return Column(
                    children: doctors.map((doc) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                      leading: const Icon(Icons.person_outline, size: 20),
                      title: Text(doc.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(doc.specialization, style: const TextStyle(fontSize: 12)),
                      trailing: Text(doc.availability, style: const TextStyle(color: Colors.green, fontSize: 12)),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
