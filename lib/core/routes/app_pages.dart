import 'package:get/get.dart';

import '../../bindings/call_binding.dart';
import '../../bindings/home_binding.dart';
import '../../views/call_history_view.dart';
import '../../views/home_view.dart';
import '../../views/incoming_call_view.dart';
import '../../views/login_view.dart';
import '../../views/ongoing_call_view.dart';
import '../../views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: SplashView.new,
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 450),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: LoginView.new,
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 420),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: HomeView.new,
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: AppRoutes.incomingCall,
      page: IncomingCallView.new,
      binding: CallBinding(),
      transition: Transition.downToUp,
    ),
    GetPage<dynamic>(
      name: AppRoutes.ongoingCall,
      page: OngoingCallView.new,
      binding: CallBinding(),
      transition: Transition.downToUp,
    ),
    GetPage<dynamic>(
      name: AppRoutes.callHistory,
      page: CallHistoryView.new,
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
