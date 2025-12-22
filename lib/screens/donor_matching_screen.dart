import 'package:flutter/material.dart';
import '../models/donor.dart';
import '../models/donation_request.dart';
import '../services/local_storage_service.dart';

class DonorMatchingScreen extends StatefulWidget {
  final DonationRequest donationRequest;

  const DonorMatchingScreen({
    super.key,
    required this.donationRequest,
  });

  @override
  State<DonorMatchingScreen> createState() => _DonorMatchingScreenState();
}

class _DonorMatchingScreenState extends State<DonorMatchingScreen> {
  final _storageService = LocalStorageService();
  List<Donor> _matchedDonors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _findMatchingDonors();
  }

  Future<void> _findMatchingDonors() async {
    try {
      final matchedDonors = await _storageService.matchDonors(
        bloodGroup: widget.donationRequest.requiredBloodGroup,
        city: widget.donationRequest.requesterCity,
        isEmergency: widget.donationRequest.requestType == 'emergency',
      );

      setState(() {
        _matchedDonors = matchedDonors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding donors: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Donors'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Request Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: widget.donationRequest.requestType == 'emergency'
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            widget.donationRequest.requestType == 'emergency'
                                ? Icons.warning_amber
                                : Icons.schedule,
                            color: widget.donationRequest.requestType == 'emergency'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.donationRequest.requestType == 'emergency'
                                ? 'EMERGENCY REQUEST'
                                : 'PLANNED REQUEST',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.donationRequest.requestType == 'emergency'
                                  ? Colors.red.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patient: ${widget.donationRequest.patientName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Blood Group: ${widget.donationRequest.requiredBloodGroup}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'City: ${widget.donationRequest.requesterCity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Hospital: ${widget.donationRequest.hospitalName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Matching Results
                Expanded(
                  child: _matchedDonors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No matching donors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'There are no available donors matching the blood group and city.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '${_matchedDonors.length} Matching Donor${_matchedDonors.length != 1 ? 's' : ''} Found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _matchedDonors.length,
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  MediaQuery.of(context).padding.bottom + 16,
                                ),
                                itemBuilder: (context, index) {
                                  final donor = _matchedDonors[index];
                                  return _buildDonorCard(donor);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDonorCard(Donor donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade700,
                  radius: 30,
                  child: Text(
                    donor.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              donor.bloodGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: donor.availabilityStatus
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              donor.availabilityStatus ? 'Available' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.location_city, 'City', donor.city),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Mobile', donor.mobileNumber),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.local_hospital, 'Organ', donor.organ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Last Donation',
              donor.lastDonationDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
