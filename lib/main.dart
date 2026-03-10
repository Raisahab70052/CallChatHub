import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/providers/local_storage_provider.dart';
import 'data/providers/firebase_messaging_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize local storage
  final LocalStorageProvider storage = await LocalStorageProvider.init();
  Get.put<LocalStorageProvider>(storage, permanent: true);
  
  // Initialize theme controller
  Get.put<ThemeController>(ThemeController(), permanent: true);
  
  // Initialize Firebase Messaging
  final FirebaseMessagingProvider messagingProvider = 
      await FirebaseMessagingProvider().init();
  Get.put<FirebaseMessagingProvider>(messagingProvider, permanent: true);

  runApp(const CallChatHubApp());
}

class CallChatHubApp extends StatelessWidget {
  const CallChatHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'CallChatHub',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
      ),
    );
  }
}
