import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/donor.dart';
import '../services/local_storage_service.dart';

class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() => _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = LocalStorageService();
  final _imagePicker = ImagePicker();

  // Form fields
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _lastDonationDateController = TextEditingController();
  
  String? _selectedOrgan;
  String? _selectedBloodGroup;
  bool _isAvailable = true;
  String? _idProofImagePath;
  String? _medicalImagePath;
  bool _isLoading = false;

  final List<String> _organs = [
    'Blood',
    'Kidney',
    'Liver',
    'Heart',
    'Lungs',
    'Pancreas',
    'Cornea',
    'Bone Marrow',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _cityController.dispose();
    _lastDonationDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isIdProof) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isIdProof) {
            _idProofImagePath = image.path;
          } else {
            _medicalImagePath = image.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _lastDonationDateController.text = 
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _registerDonor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_idProofImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload ID proof image')),
      );
      return;
    }

    if (_medicalImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload medical eligibility document')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final donor = Donor(
        id: const Uuid().v4(),
        fullName: _fullNameController.text.trim(),
        idProofImageUri: _idProofImagePath!,
        organ: _selectedOrgan!,
        bloodGroup: _selectedBloodGroup!,
        mobileNumber: _mobileNumberController.text.trim(),
        city: _cityController.text.trim(),
        lastDonationDate: _lastDonationDateController.text,
        medicalImageUri: _medicalImagePath!,
        availabilityStatus: _isAvailable,
      );

      await _storageService.saveDonor(donor);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donor registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering donor: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Registration'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mobile number';
                        }
                        if (value.length < 10) {
                          return 'Please enter valid mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Organ Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedOrgan,
                      decoration: const InputDecoration(
                        labelText: 'Organ *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: _organs.map((organ) {
                        return DropdownMenuItem(
                          value: organ,
                          child: Text(organ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrgan = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select organ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Blood Group Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bloodtype),
                      ),
                      items: _bloodGroups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodGroup = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select blood group';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City/Area *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter city/area';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Donation Date
                    TextFormField(
                      controller: _lastDonationDateController,
                      decoration: const InputDecoration(
                        labelText: 'Last Donation Date *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'YYYY-MM-DD',
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select last donation date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Availability Toggle
                    Card(
                      child: SwitchListTile(
                        title: const Text('Available for Donation'),
                        subtitle: Text(_isAvailable ? 'Currently Available' : 'Not Available'),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ID Proof Image
                    _buildImagePicker(
                      label: 'Valid ID Proof *',
                      imagePath: _idProofImagePath,
                      onTap: () => _pickImage(true),
                    ),
                    const SizedBox(height: 16),

                    // Medical Document Image
                    _buildImagePicker(
                      label: 'Medical Eligibility Document *',
                      imagePath: _medicalImagePath,
                      onTap: () => _pickImage(false),
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    ElevatedButton(
                      onPressed: _registerDonor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: imagePath == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tap to select image'),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
