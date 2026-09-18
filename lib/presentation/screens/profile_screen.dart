import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';
import '../../logic/profile_provider.dart';
import '../../logic/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFields(UserModel user) {
    if (_nameController.text.isEmpty && !_isEditing) {
      _nameController.text = user.name;
    }

    if (_phoneController.text.isEmpty && !_isEditing) {
      _phoneController.text = user.email == 'admin@enterprise.com'
          ? '+1 (555) 019-2834'
          : user.email == 'manager@enterprise.com'
          ? '+1 (555) 014-9876'
          : '+1 (555) 012-3456';
    }
  }

  Future<void> _uploadAvatar() async {
    final stateNotifier = ref.read(profileStateProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = ref.read(authStateProvider).valueOrNull;

    if (user == null) return;

    final isFirebase = ref.read(firebaseBackendProvider);

    try {
      String filePath;
      String fileName;

      if (isFirebase) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (image == null) return;
        filePath = image.path;
        fileName =
            'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      } else {
        filePath = 'mock_file_path';
        fileName = 'profile_avatar_updated_${user.id}.png';
      }

      final newUrl = await stateNotifier.uploadAvatar(filePath, fileName);

      await stateNotifier.updateProfileDetails(
        user.id,
        user.name,
        _phoneController.text.trim(),
      );

      final storage = ref.read(storageServiceProvider);
      final updatedUser = user.copyWith(avatarUrl: newUrl);
      await storage.saveUserData(updatedUser.toJson());
      ref.read(authStateProvider.notifier).updateCurrentUser(updatedUser);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Avatar uploaded successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveDetails(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(profileStateProvider.notifier)
          .updateProfileDetails(
            user.id,
            _nameController.text.trim(),
            _phoneController.text.trim(),
          );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile details updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ApiException: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profileState = ref.watch(profileStateProvider);
    final themeMode = ref.watch(themeProvider);

    if (user == null) return const Center(child: CircularProgressIndicator());

    _initFields(user);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.primary.withOpacity(0.05),
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.name.substring(0, 1),
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        if (!profileState.isUploading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: _uploadAvatar,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (profileState.isUploading) ...[
                      SizedBox(
                        width: 150,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: profileState.uploadProgress,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploading ${(profileState.uploadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.role.label} • ${user.department}',
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Personal Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isEditing ? Icons.close : Icons.edit_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _nameController.text = user.name;
                                }
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing && !profileState.isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty)
                            return 'Please enter name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        enabled: _isEditing && !profileState.isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty)
                            return 'Please enter phone';
                          return null;
                        },
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: profileState.isLoading
                              ? null
                              : () => _saveDetails(user),
                          child: profileState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Details'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.brightness_medium_outlined),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (_) =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Account Security'),
                        subtitle: Text(
                          'Role authorization level: ${user.role.label}',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          ref.read(authStateProvider.notifier).logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
