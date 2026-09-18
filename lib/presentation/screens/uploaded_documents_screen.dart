import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../data/models/user.dart';
import '../../logic/auth_provider.dart';

class UploadedDocumentsScreen extends ConsumerStatefulWidget {
  final String employeeId;
  const UploadedDocumentsScreen({super.key, required this.employeeId});

  @override
  ConsumerState<UploadedDocumentsScreen> createState() =>
      _UploadedDocumentsScreenState();
}

class _UploadedDocumentsScreenState
    extends ConsumerState<UploadedDocumentsScreen> {
  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'National_ID_Card.pdf',
      'size': '1.2 MB',
      'uploadedOn': '2026-07-01',
      'type': 'Identity Document',
    },
    {
      'name': 'Resume_CV_Alex.pdf',
      'size': '850 KB',
      'uploadedOn': '2026-07-02',
      'type': 'Resume',
    },
  ];

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    final sizeInMb = file.size / (1024 * 1024);
    if (sizeInMb > 5.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size exceeds the 5MB enterprise limit.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadingFileName = file.name;
      _uploadProgress = 0.0;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _uploadProgress = i / 10.0;
      });
    }

    setState(() {
      _documents.add({
        'name': file.name,
        'size': '${sizeInMb.toStringAsFixed(1)} MB',
        'uploadedOn': DateTime.now().toIso8601String().substring(0, 10),
        'type': file.extension?.toUpperCase() == 'PDF'
            ? 'Official Document'
            : 'Image attachment',
      });
      _isUploading = false;
      _uploadingFileName = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.name} uploaded successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteDoc(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete ${_documents[index]['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _documents.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document deleted.'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isAdmin =
        user?.role == UserRole.admin || user?.role == UserRole.manager;

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        label: const Text('Upload Document'),
        icon: const Icon(Icons.upload_file),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isUploading) ...[
              Card(
                color: AppColors.primary.withOpacity(0.08),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.hourglass_top,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Uploading $_uploadingFileName...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('${(_uploadProgress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _uploadProgress),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Compliance and Support Files',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _documents.isEmpty
                ? const Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No documents uploaded yet.',
                          style: TextStyle(color: AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final doc = _documents[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                            title: Text(
                              doc['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${doc['type']} • ${doc['size']} • Uploaded: ${doc['uploadedOn']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _deleteDoc(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
