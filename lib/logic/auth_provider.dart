import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/mock_api_interceptor.dart';
import '../core/storage/secure_storage.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import 'theme_provider.dart';
import 'auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/firebase_auth_repository_impl.dart';

final firebaseBackendProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('use_firebase_backend') ?? false;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(secureStorage: secureStorage, prefs: prefs);
});

final mockApiInterceptorProvider = Provider<MockApiInterceptor>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockApiInterceptor(prefs);
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final refreshDio = Dio(); // dedicated dio for refresh token calls
  return AuthInterceptor(storage, refreshDio);
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final mockInterceptor = ref.watch(mockApiInterceptorProvider);

  return ApiClient(
    dio: dio,
    storageService: storage,
    authInterceptor: authInterceptor,
    mockInterceptor: mockInterceptor,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useFirebase = ref.watch(firebaseBackendProvider);
  if (useFirebase && Firebase.apps.isNotEmpty) {
    return FirebaseAuthRepositoryImpl(
      firebaseAuth: fb.FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      storageService: ref.watch(storageServiceProvider),
    );
  } else {
    final apiClient = ref.watch(apiClientProvider);
    final storage = ref.watch(storageServiceProvider);
    return AuthRepositoryImpl(apiClient: apiClient, storageService: storage);
  }
});
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name, String phone, String department) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUp(email, password, {
        'name': name,
        'phone': phone,
        'department': department,
      });
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void updateCurrentUser(UserModel? user) {
    state = AsyncValue.data(user);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final authBlocProvider = Provider<AuthBloc>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final bloc = AuthBloc(repository);
  ref.onDispose(() => bloc.close());
  return bloc;
});
