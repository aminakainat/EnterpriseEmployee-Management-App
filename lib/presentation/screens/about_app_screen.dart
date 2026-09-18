import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';

class AboutApplicationScreen extends StatelessWidget {
  const AboutApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.blur_on,
              size: 80,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enterprise Ecosystem Management Suite',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0 (Build 1)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical Specifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildTechRow('UI Architecture', 'Material 3 Design System'),
                    _buildTechRow('State Architecture', 'Riverpod + Flutter BLoC'),
                    _buildTechRow('Network Layer', 'Dio Client with Token Interceptors'),
                    _buildTechRow('Local Storage', 'Flutter Secure Storage + Shared Prefs'),
                    _buildTechRow('Core Router', 'GoRouter Navigation Guards'),
                    _buildTechRow('Cloud Engine', 'Firebase Auth, Firestore, Storage'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2026 Enterprise Inc. All rights reserved. Developed to meet strict enterprise-grade security and modular Clean Architecture guidelines.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: Alignment.centerRight.x > 0 ? TextAlign.right : TextAlign.left,
              style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
