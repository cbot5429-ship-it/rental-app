import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart' show supabase;
import '../services/image_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _avatarUrl;
  bool? _isAdmin;
  String? _email;
  String? _createdAt;
  bool _loading = true;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    final data = await supabase.from('profiles').select().eq('id', user.id).single();
    if (mounted) {
      setState(() {
        _email = user.email;
        _createdAt = user.createdAt.substring(0, 10); // Just the date
        _nameCtrl.text = data['full_name'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
        _avatarUrl = data['avatar_url'];
        _isAdmin = data['is_admin'] ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _uploadAvatar() async {
    final file = await ImageService.pickSingle();
    if (file == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      // Use the existing image service to upload to a user-specific folder
      final urls = await ImageService.uploadAll([file], uid);
      final newAvatarUrl = urls.first;

      await supabase.from('profiles').update({'avatar_url': newAvatarUrl}).eq('id', uid);
      setState(() => _avatarUrl = newAvatarUrl);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('profiles').update({
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    }).eq('id', uid);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile details saved!')));
  }

  Future<void> _changePassword() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password (min 6 chars)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && ctrl.text.length >= 6) {
      await supabase.auth.updateUser(UserAttributes(password: ctrl.text));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- AVATAR ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _avatarUrl != null ? CachedNetworkImageProvider(_avatarUrl!) : null,
                    child: _avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: _uploadingAvatar 
                          ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: _uploadAvatar,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- INFO ROW ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Address'),
                subtitle: Text(_email ?? ''),
                trailing: _isAdmin == true ? const Chip(label: Text('ADMIN', style: TextStyle(fontSize: 10))) : null,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Member Since'),
                subtitle: Text(_createdAt ?? ''),
              ),
            ),
            const SizedBox(height: 24),

            // --- EDITABLE FIELDS ---
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: FilledButton(onPressed: _saveProfile, child: const Text('Save Details')),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.lock),
                onPressed: _changePassword,
                label: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}