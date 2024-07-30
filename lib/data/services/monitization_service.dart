import 'package:copycat_base/common/logging.dart';
import 'package:copycat_base/db/subscription/subscription.dart';
import 'package:copycat_pro/utils/extensions.dart';
import 'package:copycat_pro/utils/utility.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:universal_io/io.dart';

mixin MonetizationService {
  bool _setupDone = false;
  Function(Subscription subscription)? onSubscriptionAvailable;

  void setupListeners() {
    if (iapCatSupportedPlatform) {
      Purchases.addCustomerInfoUpdateListener(onCustomerInfoUpdate);
    }
  }

  void stopListeners() {
    if (iapCatSupportedPlatform) {
      Purchases.removeCustomerInfoUpdateListener(onCustomerInfoUpdate);
    }
    onSubscriptionAvailable = null;
  }

  void onCustomerInfoUpdate(CustomerInfo info) {
    final subscription = info.toSubscription();
    onSubscriptionAvailable?.call(subscription);
  }

  Future<void> setupRevenuCat(String userId) async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      const androidPubKey =
          String.fromEnvironment("REVENUECAT_ANDROID_PUB_KEY");
      configuration = PurchasesConfiguration(androidPubKey)..appUserID = userId;
    } else if (Platform.isIOS || Platform.isMacOS) {
      const applePubKey = String.fromEnvironment("REVENUECAT_APPLE_PUB_KEY");
      configuration = PurchasesConfiguration(applePubKey)..appUserID = userId;
    }
    if (configuration != null) {
      await Purchases.configure(configuration);
      _setupDone = true;
    }
  }

  Future<bool> setUser(String userId) async {
    if (iapCatSupportedPlatform) {
      if (!_setupDone) {
        await setupRevenuCat(userId);
      }

      await Purchases.logIn(userId);
      try {
        final result = await Purchases.getCustomerInfo();
        onCustomerInfoUpdate(result);
      } catch (e) {
        logger.e("Couldn't get customer info", error: e);
      }
      return true;
    }
    return false;
  }
}
