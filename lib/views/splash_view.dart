import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/image_paths.dart';
import '../core/routes/app_routes.dart';
import '../viewmodels/auth_controller.dart';
import '../widgets/gradient_background.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fade = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMs),
      () {
        final AuthController authController = Get.find<AuthController>();
        if (authController.isLoggedIn.value) {
          Get.offNamed(AppRoutes.home);
        } else {
          Get.offNamed(AppRoutes.login);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 92,
                        height: 92,
                        child: SvgPicture.asset(ImagePaths.appLogo),
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (Rect bounds) => const LinearGradient(
                          colors: <Color>[Color(0xFFA6B9FF), Color(0xFFC59CFF)],
                        ).createShader(bounds),
                        child: Text(
                          'CallChatHub',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'agora • voice • seamless',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 38),
              SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: dark ? const Color(0xFF5F7CFF) : const Color(0xFF2B4FE0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
