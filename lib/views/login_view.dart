import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/constants/image_paths.dart';
import '../core/theme/theme_controller.dart';
import '../viewmodels/auth_controller.dart';
import '../widgets/call_button.dart';
import '../widgets/glass_card_widget.dart';
import '../widgets/gradient_background.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Obx(
                            () => SegmentedButton<ThemeMode>(
                              selected: <ThemeMode>{themeController.themeMode.value},
                              onSelectionChanged: (_) =>
                                  themeController.toggleTheme(),
                              segments: const <ButtonSegment<ThemeMode>>[
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode_rounded),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.88, end: 1),
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: SizedBox(
                              width: 78,
                              height: 78,
                              child: SvgPicture.asset(ImagePaths.appLogo),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Text(
                            controller.isSignUpMode.value ? 'create account' : 'welcome',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        Text(
                          'to CallChatHub',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 12, end: 0),
                          duration: const Duration(milliseconds: 550),
                          curve: Curves.easeOut,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: child,
                            );
                          },
                          child: GlassCardWidget(
                            radius: 36,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: controller.emailController,
                                  focusNode: controller.emailFocus,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(controller.passwordFocus),
                                  validator: controller.validateEmail,
                                  decoration: const InputDecoration(
                                    hintText: 'email or phone',
                                    prefixIcon: Icon(Icons.person_outline_rounded),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Obx(
                                  () => TextFormField(
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocus,
                                    obscureText: controller.obscurePassword.value,
                                    validator: controller.validatePassword,
                                    decoration: InputDecoration(
                                      hintText: 'password',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        onPressed: controller.togglePasswordVisibility,
                                        icon: Icon(
                                          controller.obscurePassword.value
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Obx(
                                  () => controller.isLoading.value
                                      ? const CircularProgressIndicator()
                                      : SizedBox(
                                          width: double.infinity,
                                          child: CallButton(
                                            label: controller.isSignUpMode.value
                                                ? 'Sign Up'
                                                : 'Log In',
                                            icon: Icons.arrow_forward_rounded,
                                            onTap: controller.loginOrSignup,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => controller.isSignUpMode.value
                                      ? const SizedBox.shrink()
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: controller.forgotPassword,
                                            child: const Text('forgot password?'),
                                          ),
                                        ),
                                ),
                                Obx(
                                  () => TextButton(
                                    onPressed: controller.toggleAuthMode,
                                    child: Text(
                                      controller.isSignUpMode.value
                                          ? 'already have an account? log in'
                                          : 'create account',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
