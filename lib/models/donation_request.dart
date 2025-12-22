class DonationRequest {
  final String id;
  final String patientName;
  final String requiredBloodGroup;
  final String medicalDocumentImageUri;
  final String mobileNumber;
  final String requestType; // 'emergency' or 'planned'
  final String hospitalName;
  final String description;
  final String requesterCity;
  final DateTime createdAt;

  DonationRequest({
    required this.id,
    required this.patientName,
    required this.requiredBloodGroup,
    required this.medicalDocumentImageUri,
    required this.mobileNumber,
    required this.requestType,
    required this.hospitalName,
    required this.description,
    required this.requesterCity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'requiredBloodGroup': requiredBloodGroup,
      'medicalDocumentImageUri': medicalDocumentImageUri,
      'mobileNumber': mobileNumber,
      'requestType': requestType,
      'hospitalName': hospitalName,
      'description': description,
      'requesterCity': requesterCity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      requiredBloodGroup: json['requiredBloodGroup'] as String,
      medicalDocumentImageUri: json['medicalDocumentImageUri'] as String,
      mobileNumber: json['mobileNumber'] as String,
      requestType: json['requestType'] as String,
      hospitalName: json['hospitalName'] as String,
      description: json['description'] as String,
      requesterCity: json['requesterCity'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
