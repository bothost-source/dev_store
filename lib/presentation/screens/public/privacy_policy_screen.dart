import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('Privacy Policy', style: TextStyle(color: Colors.white))),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 16),
            Text(
              'Last updated: july 2026\n\n'
              '1. Information We Collect\n'
              'We collect information you provide directly to us, including your name, email address, and any apps you upload.\n\n'
              '2. How We Use Your Information\n'
              'We use the information to provide, maintain, and improve our services, and to communicate with you.\n\n'
              '3. Information Sharing\n'
              'We do not sell your personal information. We may share information with service providers who assist us in operating our platform.\n\n'
              '4. Security\n'
              'We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.\n\n'
              '5. Your Choices\n'
              'You may update, correct, or delete your account information at any time by accessing your account settings.\n\n'
              '6. Contact Us: verifieddevstore2026@gmail.com\n'
              'If you have any questions about this Privacy Policy, please contact us.',
              style: TextStyle(color: Colors.white70, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
