import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/donor.dart';
import '../models/donation_request.dart';

class LocalStorageService {
  static const String _donorsFile = 'donors.json';
  static const String _requestsFile = 'donation_requests.json';

  // Get the local file path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get donors file
  Future<File> get _donorsJsonFile async {
    final path = await _localPath;
    return File('$path/$_donorsFile');
  }

  // Get donation requests file
  Future<File> get _requestsJsonFile async {
    final path = await _localPath;
    return File('$path/$_requestsFile');
  }

  // Initialize storage by copying from assets if needed
  Future<void> initializeStorage() async {
    final donorsFile = await _donorsJsonFile;
    final requestsFile = await _requestsJsonFile;

    // Copy from assets if files don't exist
    if (!await donorsFile.exists()) {
      final data = await rootBundle.loadString('assets/resource/donors.json');
      await donorsFile.writeAsString(data);
    }

    if (!await requestsFile.exists()) {
      final data = await rootBundle.loadString('assets/resource/donation_requests.json');
      await requestsFile.writeAsString(data);
    }
  }

  // Save donors to local storage
  Future<void> saveDonor(Donor donor) async {
    await initializeStorage();
    final donors = await getAllDonors();
    donors.add(donor);
    
    final file = await _donorsJsonFile;
    final jsonList = donors.map((d) => d.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Get all donors from local storage
  Future<List<Donor>> getAllDonors() async {
    await initializeStorage();
    
    final file = await _donorsJsonFile;
    final contents = await file.readAsString();
    
    if (contents.isEmpty || contents == '[]') {
      return [];
    }
    
    final List<dynamic> jsonList = jsonDecode(contents);
    return jsonList.map((json) => Donor.fromJson(json)).toList();
  }

  // Save donation request to local storage
  Future<void> saveDonationRequest(DonationRequest request) async {
    await initializeStorage();
    final requests = await getAllDonationRequests();
    requests.add(request);
    
    final file = await _requestsJsonFile;
    final jsonList = requests.map((r) => r.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Get all donation requests from local storage
  Future<List<DonationRequest>> getAllDonationRequests() async {
    await initializeStorage();
    
    final file = await _requestsJsonFile;
    final contents = await file.readAsString();
    
    if (contents.isEmpty || contents == '[]') {
      return [];
    }
    
    final List<dynamic> jsonList = jsonDecode(contents);
    return jsonList.map((json) => DonationRequest.fromJson(json)).toList();
  }

  // Match donors based on criteria
  Future<List<Donor>> matchDonors({
    required String bloodGroup,
    required String city,
    required bool isEmergency,
  }) async {
    final donors = await getAllDonors();
    
    // Filter donors based on matching criteria
    final matchedDonors = donors.where((donor) {
      return donor.bloodGroup == bloodGroup &&
             donor.city.toLowerCase() == city.toLowerCase() &&
             donor.availabilityStatus == true;
    }).toList();
    
    // Sort: Emergency requests get priority (no specific sorting needed here,
    // but this could be extended if donors had priority levels)
    return matchedDonors;
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final donorsFile = await _donorsJsonFile;
    final requestsFile = await _requestsJsonFile;
    await donorsFile.writeAsString('[]');
    await requestsFile.writeAsString('[]');
  }
}
