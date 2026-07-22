import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('Terms of Service', style: TextStyle(color: Colors.white))),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms of Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 16),
            Text(
              'Last updated: July 2026\n\n'
              '1. Acceptance of Terms\n'
              'By accessing or using DEVSTORE, you agree to be bound by these Terms of Service.\n\n'
              '2. Developer Accounts\n'
              'Developers must provide accurate information and are responsible for all apps uploaded to the platform.\n\n'
              '3. Content Guidelines\n'
              'All uploaded apps must comply with our content guidelines. We reserve the right to remove any app that violates these guidelines.\n\n'
              '4. Intellectual Property\n'
              'You retain ownership of your apps. By uploading, you grant us a license to distribute your apps through our platform.\n\n'
              '5. Termination\n'
              'We may terminate or suspend your account at any time for violations of these terms.\n\n'
              '6. Limitation of Liability\n'
              'DEVSTORE is provided "as is" without warranties of any kind.\n\n'
              '7. Changes to Terms\n'
              'We may modify these terms at any time. Continued use of the platform constitutes acceptance of the modified terms.',
              style: TextStyle(color: Colors.white70, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
