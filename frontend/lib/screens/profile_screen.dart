import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/error_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const route = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  final _preferredRolesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().user?.profile;
    _skillsController.text = profile?.skills ?? '';
    _experienceController.text = profile?.experience ?? '';
    _locationController.text = profile?.location ?? '';
    _preferredRolesController.text = profile?.preferredRoles ?? '';
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _preferredRolesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<AuthProvider>();
    final profile = UserProfile(
      skills: _skillsController.text.trim(),
      experience: _experienceController.text.trim(),
      location: _locationController.text.trim(),
      preferredRoles: _preferredRolesController.text.trim(),
      remotePreference: 'hybrid',
    );

    final ok = await provider.saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profile saved' : (provider.error ?? 'Failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills')),
            const SizedBox(height: 12),
            TextField(
              controller: _experienceController,
              decoration: const InputDecoration(labelText: 'Experience'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 12),
            TextField(
              controller: _preferredRolesController,
              decoration: const InputDecoration(labelText: 'Preferred Roles'),
            ),
            const SizedBox(height: 16),
            if (auth.error != null) ErrorMessage(message: auth.error!),
            ElevatedButton(onPressed: auth.isLoading ? null : _save, child: const Text('Save Profile')),
          ],
        ),
      ),
    );
  }
}
