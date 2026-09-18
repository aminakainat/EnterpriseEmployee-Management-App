import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../data/models/notification.dart';
import '../../logic/employee_provider.dart';
import '../../logic/notification_provider.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedReceiverId = 'All'; // 'All' or specific employee id
  NotificationType _selectedType = NotificationType.info;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final title = _titleController.text.trim();
      final message = _messageController.text.trim();

      await ref
          .read(notificationStateProvider.notifier)
          .sendBroadcastNotification(
            title: title,
            message: message,
            receiverId: _selectedReceiverId,
            type: _selectedType,
          );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Notification broadcast completed!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) {
        context.go('/settings');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeeStateProvider).employees;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppLayout.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Message Title',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        prefixIcon: Icon(Icons.chat_bubble_outline),
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter message details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedReceiverId,
                      decoration: const InputDecoration(
                        labelText: 'Recipient',
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text('Broadcast to All Employees'),
                        ),
                        ...employees.map(
                          (emp) => DropdownMenuItem(
                            value: emp.id,
                            child: Text(emp.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedReceiverId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<NotificationType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Category / Severity',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: NotificationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _send,
                      child: const Text('Send Notification'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
