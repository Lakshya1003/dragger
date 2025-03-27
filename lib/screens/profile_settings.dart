import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/cloudinary_service.dart';
import '../config/cloudinary_config.dart';
import 'login_screen.dart';
import 'dart:typed_data';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _languagesController = TextEditingController();

  String? profileImageUrl;
  bool isLoading = false;
  String? _cloudinaryError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('athletes')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _cityController.text = data['city'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _qualificationController.text = data['qualification'] ?? '';
          _languagesController.text = data['languages'] ?? '';
          profileImageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (!CloudinaryConfig.isValid()) {
      setState(() {
        _cloudinaryError =
            'Invalid Cloudinary configuration: ${CloudinaryConfig.getDebugInfo()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cloudinaryError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          dynamic fileToUpload;

          if (kIsWeb) {
            // For web, read the file as bytes
            fileToUpload = await image.readAsBytes();
          } else {
            // For mobile, use the file path
            fileToUpload = File(image.path);
          }

          final imageUrl =
              await CloudinaryService.instance.uploadImage(fileToUpload);

          await FirebaseFirestore.instance
              .collection('athletes')
              .doc(user.uid)
              .update({'profileImageUrl': imageUrl});

          setState(() => profileImageUrl = imageUrl);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cloudinaryError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error in _pickImage: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('athletes')
              .doc(user.uid)
              .update({
            'name': _nameController.text,
            'bio': _bioController.text,
            'age': int.tryParse(_ageController.text),
            'city': _cityController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'qualification': _qualificationController.text,
            'languages': _languagesController.text,
            'additionalDetails': {
              'qualification': _qualificationController.text,
              'languages': _languagesController.text,
            },
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image Upload
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 3),
                          image: profileImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image:
                                      AssetImage('assets/default_profile.png'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Required Fields
                    _buildTextField(
                      controller: _nameController,
                      label: 'Athlete Name *',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio *',
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Bio is required' : null,
                    ),

                    // Optional Fields
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),

                    // Additional Details Section
                    const SizedBox(height: 24),
                    const Text(
                      'Additional Details',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _qualificationController,
                      label: 'Qualification',
                    ),
                    _buildTextField(
                      controller: _languagesController,
                      label: 'Languages',
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _logout,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
      ),
    );
  }
}
