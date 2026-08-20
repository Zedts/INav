import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/theme_toggle_button.dart';
import 'auth_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: const ThemeToggleButton(),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 256,
                    height: 108,
                    child: Image.asset(
                      dark ? AppImages.iconDark : AppImages.iconWhite,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your companion for prayer times, Qibla direction, and the Qur’an — wherever you are.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _Feature(Icons.schedule, 'PRAYER TIMES'),
                      _Feature(Icons.explore_outlined, 'QIBLA'),
                      _Feature(Icons.menu_book_outlined, 'QURAN'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AuthScreen(register: true),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Get Started'),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        children: const [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 21),
      const SizedBox(height: 8),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Theme.of(context).hintColor,
        ),
      ),
    ],
  );
}
