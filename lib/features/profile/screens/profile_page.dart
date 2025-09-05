import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _supabaseService.getProfile();
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  /// 🔹 Upload Image to Supabase Storage
  Future<String?> _uploadAvatar(File file) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final fileExt = file.path.split('.').last;
      final fileName = '${user.id}.${fileExt}';
      final filePath = 'avatars/$fileName';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Public URL
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _profile?['name'] ?? "");
    final sportController = TextEditingController(text: _profile?['sport'] ?? "");
    final ageController = TextEditingController(text: _profile?['age']?.toString() ?? "");
    final bioController = TextEditingController(text: _profile?['bio'] ?? "");

    File? pickedImage;
    String? uploadedUrl;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setStateDialog(() {
                            pickedImage = File(picked.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage!)
                            : (_profile?['avatar_url'] != null &&
                            _profile!['avatar_url'].toString().isNotEmpty)
                            ? NetworkImage(_profile!['avatar_url'])
                            : null,
                        child: pickedImage == null &&
                            (_profile?['avatar_url'] == null ||
                                _profile!['avatar_url'].toString().isEmpty)
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: sportController,
                      decoration: const InputDecoration(labelText: "Sport"),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: bioController,
                      decoration: const InputDecoration(labelText: "Bio"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      if (pickedImage != null) {
                        uploadedUrl = await _uploadAvatar(pickedImage!);
                      }

                      await Supabase.instance.client.from('profiles').update({
                        'name': nameController.text,
                        'sport': sportController.text,
                        'age': int.tryParse(ageController.text),
                        'bio': bioController.text,
                        if (uploadedUrl != null) 'avatar_url': uploadedUrl,
                      }).eq('id', user.id);

                      Navigator.pop(context);
                      _loadProfile(); // refresh
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _profile == null ? null : _editProfile,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text("No profile found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: _profile!['avatar_url'] != null &&
                  _profile!['avatar_url'].toString().isNotEmpty
                  ? NetworkImage(_profile!['avatar_url'])
                  : null,
              child: _profile!['avatar_url'] == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            // 🔹 Name
            Text(
              _profile!['name'] ?? "Athlete",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 🔹 Email
            Text(
              Supabase.instance.client.auth.currentUser?.email ??
                  "No email",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Profile Details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow("Sport", _profile!['sport'] ?? "N/A"),
                    _buildInfoRow("Age", _profile!['age']?.toString() ?? "N/A"),
                    _buildInfoRow("Bio", _profile!['bio'] ?? "No bio yet"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Logout Button
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
