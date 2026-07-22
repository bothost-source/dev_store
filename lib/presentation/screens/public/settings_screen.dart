import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../bloc/auth_bloc.dart';
import '../auth/login_screen.dart';
import '../developer/developer_dashboard_screen.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'package:devstore/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.settings, style: const TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.white),
            title: Text(l10n.darkMode, style: const TextStyle(color: Colors.white)),
            trailing: Switch(
              activeColor: Colors.white,
              activeTrackColor: Colors.white70,
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto, color: Colors.white),
            title: Text(l10n.systemTheme, style: const TextStyle(color: Colors.white)),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setThemeMode(value!),
              activeColor: Colors.white,
            ),
          ),

          const _SectionHeader(title: 'Developer'),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.white),
            title: const Text('Developer Mode', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Upload and manage your apps', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            onTap: () => _showDeveloperWarning(context),
          ),

          const _SectionHeader(title: 'Language'),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
            subtitle: Text(_getLanguageName(localeProvider.locale.languageCode), style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => _showLanguagePicker(context),
          ),

          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.white),
            title: Text(l10n.appUpdates, style: const TextStyle(color: Colors.white)),
            value: true,
            onChanged: (value) {},
            activeColor: Colors.white,
            activeTrackColor: Colors.white70,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.new_releases, color: Colors.white),
            title: Text(l10n.newApps, style: const TextStyle(color: Colors.white)),
            value: true,
            onChanged: (value) {},
            activeColor: Colors.white,
            activeTrackColor: Colors.white70,
          ),

          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: Text(l10n.profile, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.white),
            title: Text(l10n.changePassword, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),

          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: Text(l10n.about, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: Text(l10n.privacyPolicy, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.white),
            title: Text(l10n.termsOfService, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsScreen())),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout, color: Colors.black),
              label: Text(l10n.logout, style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDeveloperWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white24)),
        title: const Row(children: [Icon(Icons.warning_amber, color: Colors.white), SizedBox(width: 8), Text('Developer Access', style: TextStyle(color: Colors.white))]),
        content: const Text(
          'This section is strictly for developers.\n\nRandom or inappropriate uploads will result in immediate account restrictions.\n\nOnly upload apps you have permission to distribute. All uploads are reviewed before approval.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeveloperDashboardScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final names = {'en': 'English', 'fr': 'Français', 'es': 'Español'};
    return names[code] ?? code;
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.language, color: Colors.white), title: Text(l10n.english, style: const TextStyle(color: Colors.white)), trailing: localeProvider.locale.languageCode == 'en' ? const Icon(Icons.check, color: Colors.white) : null, onTap: () { localeProvider.setLocale('en'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.language, color: Colors.white), title: Text(l10n.french, style: const TextStyle(color: Colors.white)), trailing: localeProvider.locale.languageCode == 'fr' ? const Icon(Icons.check, color: Colors.white) : null, onTap: () { localeProvider.setLocale('fr'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.language, color: Colors.white), title: Text(l10n.spanish, style: const TextStyle(color: Colors.white)), trailing: localeProvider.locale.languageCode == 'es' ? const Icon(Icons.check, color: Colors.white) : null, onTap: () { localeProvider.setLocale('es'); Navigator.pop(context); }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1)));
}
