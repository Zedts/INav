import 'package:flutter/material.dart';

class TermsPrivacyModal extends StatelessWidget {
  const TermsPrivacyModal({super.key, required this.title});
  final String title;
  static Future<void> show(BuildContext context, String title) => showDialog(
    context: context,
    builder: (_) => TermsPrivacyModal(title: title),
  );
  @override
  Widget build(BuildContext context) => Dialog(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Coming soon. Full legal text will be available here.'),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    ),
  );
}
