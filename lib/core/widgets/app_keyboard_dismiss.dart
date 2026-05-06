import 'package:flutter/material.dart';

class AppKeyboardDismiss extends StatelessWidget {
  const AppKeyboardDismiss({
    super.key,
    required this.child,
  });

  final Widget child;

  static void dismiss(BuildContext context) {
    final scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus && scope.focusedChild != null) {
      scope.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => dismiss(context),
      child: child,
    );
  }
}
