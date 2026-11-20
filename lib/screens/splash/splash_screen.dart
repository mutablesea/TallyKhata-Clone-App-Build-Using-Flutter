import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/tk_logo.dart';

/// Two-stage splash screen:
/// Stage 1: Rounded icon box (this project's design)
/// Stage 2: Full TallyKhata branded splash with Bangladesh Bank & security badges (from mycode assets)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _full = false;
  Timer? _t1;
  Timer? _t2;

  @override
  void initState() {
    super.initState();
    _t1 = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _full = true);
    });
    _t2 = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      final registered = AppScope.read(context).isRegistered;
      Navigator.pushReplacementNamed(
        context,
        registered ? AppRoutes.main : AppRoutes.login,
      );
    });
  }

  @override
  void dispose() {
    _t1?.cancel();
    _t2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _full
            ? const _FullSplash(key: ValueKey('full'))
            : const _IconSplash(key: ValueKey('icon')),
      ),
    );
  }
}

class _IconSplash extends StatelessWidget {
  const _IconSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(child: TkLogo(size: 56)),
      ),
    );
  }
}

class _FullSplash extends StatelessWidget {
  const _FullSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            Image.asset('assets/images/tallykhata_logo1.png', width: 220),
            const SizedBox(height: 20),
            Image.asset('assets/images/tallykhata_logo2.jpg', width: 170),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Image.asset(
                'assets/images/tallykhata_logo3.jpg',
                width: 125,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
