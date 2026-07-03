import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../bloc/auth_bloc.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';
import '../developer/developer_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAdmin = state is Authenticated && state.user.isAdmin;
        final isDeveloper = state is Authenticated && state.user.isDeveloper;

        final screens = [
          const HomeScreen(),
          const SearchScreen(),
          const DownloadsScreen(),
          if (isDeveloper) const DeveloperDashboardScreen(),
          if (isAdmin) const AdminDashboardScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            isDeveloper: isDeveloper,
            isAdmin: isAdmin,
          ),
        );
      },
    );
  }
}
