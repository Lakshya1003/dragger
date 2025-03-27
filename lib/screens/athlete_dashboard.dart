import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import '../config/cloudinary_config.dart';
import 'profile_settings.dart';
import 'explore_page.dart';
import 'tools_page.dart';
import 'search_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/web_file_picker.dart'
    if (dart.library.io) '../services/mobile_file_picker.dart';

class AthleteDashboard extends StatefulWidget {
  const AthleteDashboard({super.key});

  @override
  State<AthleteDashboard> createState() => _AthleteDashboardState();
}

class _AthleteDashboardState extends State<AthleteDashboard>
    with SingleTickerProviderStateMixin {
  String? profileImageUrl;
  String athleteName = '';
  String bio = '';
  String city = '';
  Map<String, dynamic>? additionalDetails;
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  bool isLoading = false;
  late CloudinaryService _cloudinaryService;
  String? _cloudinaryError;

  @override
  void initState() {
    super.initState();
    _initializeCloudinary();
    _loadAthleteData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  void _initializeCloudinary() {
    try {
      _cloudinaryService = CloudinaryService.instance;
      setState(() {
        _cloudinaryError = null;
      });
    } catch (e) {
      setState(() {
        _cloudinaryError = e.toString();
      });
      debugPrint('Error initializing Cloudinary: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAthleteData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('athletes')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          athleteName = doc.data()?['name'] ?? '';
          bio = doc.data()?['bio'] ?? '';
          city = doc.data()?['city'] ?? '';
          additionalDetails = doc.data()?['additionalDetails'];
        });
      }

      // Fetch profile image URL from Firebase
      final imageUrl = await _fetchProfileImage(user.uid);
      if (imageUrl != null) {
        setState(() {
          profileImageUrl = imageUrl;
        });
      }
    }
  }

  Future<String> _fetchProfileImage(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('athletes')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()?['profileImageUrl'] != null) {
        return doc.data()!['profileImageUrl'];
      }
      return 'assets/default_profile.png';
    } catch (e) {
      print('Error fetching profile image: $e');
      return 'assets/default_profile.png';
    }
  }

  Future<String> _pickAndUploadImage() async {
    try {
      if (kIsWeb) {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) return '';

        // Read the file as bytes for web
        final bytes = await image.readAsBytes();
        final imageUrl = await _cloudinaryService.uploadImage(bytes);

        // Update Firestore with the new image URL
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('athletes')
              .doc(user.uid)
              .update({'profileImageUrl': imageUrl});
        }

        return imageUrl;
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) return '';

        // Upload to Cloudinary
        final imageUrl = await _cloudinaryService.uploadImage(File(image.path));

        // Update Firestore with the new image URL
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('athletes')
              .doc(user.uid)
              .update({'profileImageUrl': imageUrl});
        }

        return imageUrl;
      }
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cloudinaryError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Configuration Error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cloudinaryError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _initializeCloudinary();
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.orange, width: 3),
                              ),
                              child: ClipOval(
                                child: profileImageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: profileImageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                          color: Colors.orange,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/default_profile.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/default_profile.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            if (isLoading)
                              const CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            if (!isLoading)
                              const Icon(
                                Icons.camera_alt,
                                color: Colors.orange,
                                size: 40,
                              ),
                          ],
                        ),
                      ),

                      // Athlete Name
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          athleteName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Bio Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          bio,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // City
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Additional Details Section
                      if (additionalDetails != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Additional Details',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Qualification: ${additionalDetails!['qualification'] ?? 'Not specified'}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Languages: ${additionalDetails!['languages'] ?? 'Not specified'}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Gear Icon in top-right corner
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettings(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIcon(Icons.explore, 'Explore', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExplorePage(),
                  ),
                );
              }, 0),
              _buildNavIcon(Icons.search, 'Search', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              }, 1),
              _buildNavIcon(Icons.add_circle, 'Add Media', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Media page coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }, 2),
              _buildNavIcon(Icons.person, 'Profile', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are already on your profile'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 1),
                  ),
                );
              }, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ToolsPage(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.build, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
      IconData icon, String label, VoidCallback onTap, int index) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animations[index],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
