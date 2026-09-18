import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/firebase_profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import 'auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final bool isUploading;
  final double uploadProgress;
  final String? uploadedFileUrl;
  final String? errorMessage;

  ProfileState({
    required this.isLoading,
    required this.isUploading,
    required this.uploadProgress,
    this.uploadedFileUrl,
    this.errorMessage,
  });

  factory ProfileState.initial() {
    return ProfileState(
      isLoading: false,
      isUploading: false,
      uploadProgress: 0.0,
    );
  }

  ProfileState copyWith({
    bool? isLoading,
    bool? isUploading,
    double? uploadProgress,
    String? uploadedFileUrl,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadedFileUrl: uploadedFileUrl ?? this.uploadedFileUrl,
      errorMessage: errorMessage,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseProfileRepositoryImpl(
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
    );
  } else {
    final apiClient = ref.watch(apiClientProvider);
    return ProfileRepositoryImpl(apiClient);
  }
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(ProfileState.initial());

  Future<String> uploadAvatar(String filePath, String fileName) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0.0,
      errorMessage: null,
    );

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      state = state.copyWith(uploadProgress: i / 10.0);
    }

    try {
      final fileUrl = await _repository.uploadProfilePicture(
        filePath,
        fileName,
      );
      state = state.copyWith(isUploading: false, uploadedFileUrl: fileUrl);
      return fileUrl;
    } catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateProfileDetails(
    String id,
    String name,
    String phone,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedUser = await _repository.updateProfile(id, {
        'name': name,
        'phone': phone,
      });

      final storage = _ref.read(storageServiceProvider);
      await storage.saveUserData(updatedUser.toJson());

      _ref.read(authStateProvider.notifier).updateCurrentUser(updatedUser);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final profileStateProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ProfileNotifier(repository, ref);
    });
