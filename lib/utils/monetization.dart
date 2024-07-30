import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

Future<void> presentPaywall() async {
  await RevenueCatUI.presentPaywall(
    displayCloseButton: true,
  );
}
