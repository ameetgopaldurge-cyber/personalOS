import 'package:flutter/material.dart';
import 'providers/os_controller.dart';
import 'screens/content_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/home_discipline_screen.dart';
import 'screens/income_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/studies_screen.dart';
import 'theme/os_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PersonalOSApp());
}

class PersonalOSApp extends StatefulWidget {
  const PersonalOSApp({super.key});

  @override
  State<PersonalOSApp> createState() => _PersonalOSAppState();
}

class _PersonalOSAppState extends State<PersonalOSApp> {
  final PersonalOSController _controller = PersonalOSController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal OS',
      debugShowCheckedModeBanner: false,
      theme: PersonalOSTheme.darkTheme,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final screens = [
            HomeDisciplineScreen(
              controller: _controller,
              onNavigateTab: _onSelectTab,
            ),
            StudiesScreen(controller: _controller),
            FitnessScreen(controller: _controller),
            ContentScreen(controller: _controller),
            SkillsScreen(controller: _controller),
            IncomeScreen(controller: _controller),
          ];

          return Scaffold(
            body: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: PersonalOSTheme.surfaceCard,
                border: Border(
                  top: BorderSide(
                    color: PersonalOSTheme.borderSubtle,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavBarItem(
                        icon: Icons.dashboard_rounded,
                        label: 'OS Hub',
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onSelectTab(0),
                      ),
                      _NavBarItem(
                        icon: Icons.school_rounded,
                        label: 'Studies',
                        isSelected: _selectedIndex == 1,
                        badgeAlert: _controller.subjects
                            .any((s) => s.isAttendanceLow),
                        onTap: () => _onSelectTab(1),
                      ),
                      _NavBarItem(
                        icon: Icons.fitness_center_rounded,
                        label: 'Fitness',
                        isSelected: _selectedIndex == 2,
                        onTap: () => _onSelectTab(2),
                      ),
                      _NavBarItem(
                        icon: Icons.movie_creation_rounded,
                        label: 'Content',
                        isSelected: _selectedIndex == 3,
                        onTap: () => _onSelectTab(3),
                      ),
                      _NavBarItem(
                        icon: Icons.code_rounded,
                        label: 'Skills',
                        isSelected: _selectedIndex == 4,
                        onTap: () => _onSelectTab(4),
                      ),
                      _NavBarItem(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Income',
                        isSelected: _selectedIndex == 5,
                        onTap: () => _onSelectTab(5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool badgeAlert;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeAlert = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? PersonalOSTheme.primaryPurple.withOpacity(0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? PersonalOSTheme.primaryPurple
                      : PersonalOSTheme.textSecondary,
                ),
                if (badgeAlert)
                  Positioned(
                    right: -3,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: PersonalOSTheme.coralRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? PersonalOSTheme.primaryPurple
                    : PersonalOSTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
