import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/theme_controller.dart';
import '../viewmodels/auth_controller.dart';
import '../viewmodels/home_controller.dart';
import '../widgets/bottom_nav_widget.dart';
import '../widgets/call_button.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/user_row_widget.dart';
import '../widgets/gradient_background.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      floatingActionButton: CallButton(
        label: 'New',
        icon: Icons.add_call,
        onTap: () {
          if (controller.filteredUsers.isNotEmpty) {
            controller.makeCall(controller.filteredUsers.first);
          }
        },
        round: true,
      ),
      body: GradientBackground(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('chats', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                Obx(
                  () => IconButton(
                    onPressed: themeController.toggleTheme,
                    icon: Icon(
                      themeController.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.openHistory,
                  icon: const Icon(Icons.history_rounded),
                ),
                IconButton(
                  onPressed: authController.logout,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            TextField(
              onChanged: controller.updateSearch,
              decoration: const InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const LoadingShimmer();
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshUsers,
                    child: controller.filteredUsers.isEmpty
                        ? ListView(
                            children: const <Widget>[
                              SizedBox(height: 120),
                              Center(child: Text('No contacts found')),
                            ],
                          )
                        : ListView.builder(
                            itemCount: controller.filteredUsers.length,
                            itemBuilder: (_, int index) {
                              final user = controller.filteredUsers[index];
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 180 + (index * 40)),
                                curve: Curves.easeOut,
                                child: UserRowWidget(
                                  user: user,
                                  onCallTap: () => controller.makeCall(user),
                                  onLongPress: () => controller.showQuickActions(user),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
            const BottomNavWidget(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}
