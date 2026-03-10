import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<IconData> icons = <IconData>[
      Icons.home_rounded,
      Icons.history_rounded,
      Icons.contacts_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xB3141624) : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: dark ? const Color(0x22FFFFFF) : const Color(0x22001428),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(icons.length, (int index) {
          final bool active = index == currentIndex;
          return IconButton(
            onPressed: () {
              if (index == 0) Get.offAllNamed(AppRoutes.home);
              if (index == 1) Get.toNamed(AppRoutes.callHistory);
            },
            icon: Icon(
              icons[index],
              color: active
                  ? (dark ? const Color(0xFF5F7CFF) : const Color(0xFF2B4FE0))
                  : (dark ? const Color(0xFF9DA6C0) : const Color(0xFF4A5675)),
            ),
          );
        }),
      ),
    );
  }
}
