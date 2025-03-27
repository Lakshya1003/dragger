import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'athlete_dashboard.dart';
import 'profile_settings.dart';
import 'explore_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchAthletes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final name = _nameController.text.toLowerCase();
        final city = _cityController.text.toLowerCase();

        Query query = FirebaseFirestore.instance.collection('athletes');

        // Apply name filter
        query = query
            .where('nameLower', isGreaterThanOrEqualTo: name)
            .where('nameLower', isLessThanOrEqualTo: name + '\uf8ff');

        // Apply city filter if provided
        if (city.isNotEmpty) {
          query = query
              .where('cityLower', isGreaterThanOrEqualTo: city)
              .where('cityLower', isLessThanOrEqualTo: city + '\uf8ff');
        }

        final querySnapshot = await query.get();

        setState(() {
          searchResults = querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? '',
              'city': data['city'] ?? '',
              'bio': data['bio'] ?? '',
              'profileImageUrl': data['profileImageUrl'],
            };
          }).toList();
          isLoading = false;
        });

        // Show results count
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${searchResults.length} athletes'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error searching athletes: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          'Search',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Search Input Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Athlete Name *',
                      labelStyle: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an athlete name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Athlete City',
                      labelStyle: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _searchAthletes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.search, size: 24),
                    label: const Text(
                      'Search',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No athletes found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final athlete = searchResults[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: athlete['profileImageUrl'] !=
                                          null
                                      ? NetworkImage(athlete['profileImageUrl'])
                                      : const AssetImage(
                                              'assets/default_profile.png')
                                          as ImageProvider,
                                  backgroundColor: Colors.orange,
                                ),
                                title: Text(
                                  athlete['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  athlete['city'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                onTap: () {
                                  // Navigate to athlete profile
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Athlete profile coming soon!'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
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
              _buildNavIcon(Icons.search, 'Search', () {}, 1),
              _buildNavIcon(Icons.add_circle, 'Add Media', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Media page coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }, 2),
              _buildNavIcon(Icons.person, 'Profile', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettings(),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tools page coming soon!'),
                backgroundColor: Colors.orange,
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
