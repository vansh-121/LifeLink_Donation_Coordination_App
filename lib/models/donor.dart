class Donor {
  final String id;
  final String fullName;
  final String idProofImageUri;
  final String organ;
  final String bloodGroup;
  final String mobileNumber;
  final String city;
  final String lastDonationDate;
  final String medicalImageUri;
  final bool availabilityStatus;

  Donor({
    required this.id,
    required this.fullName,
    required this.idProofImageUri,
    required this.organ,
    required this.bloodGroup,
    required this.mobileNumber,
    required this.city,
    required this.lastDonationDate,
    required this.medicalImageUri,
    required this.availabilityStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'idProofImageUri': idProofImageUri,
      'organ': organ,
      'bloodGroup': bloodGroup,
      'mobileNumber': mobileNumber,
      'city': city,
      'lastDonationDate': lastDonationDate,
      'medicalImageUri': medicalImageUri,
      'availabilityStatus': availabilityStatus,
    };
  }

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      idProofImageUri: json['idProofImageUri'] as String,
      organ: json['organ'] as String,
      bloodGroup: json['bloodGroup'] as String,
      mobileNumber: json['mobileNumber'] as String,
      city: json['city'] as String,
      lastDonationDate: json['lastDonationDate'] as String,
      medicalImageUri: json['medicalImageUri'] as String,
      availabilityStatus: json['availabilityStatus'] as bool,
    );
  }
}
