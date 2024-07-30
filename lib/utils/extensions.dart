import 'package:copycat_base/db/subscription/subscription.dart';
import 'package:copycat_base/domain/model/auth_user/auth_user.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

extension AuthUserExtension on sb.User {
  AuthUser toAuthUser() {
    return AuthUser(
      userId: id,
      email: email!,
      displayName: userMetadata?["display_name"],
      enc2KeyId: userMetadata?["enc2KeyId"],
      enc1: userMetadata?["enc1"],
    );
  }
}

extension CustomerInfoExtension on CustomerInfo {
  Subscription toSubscription() {
    final proEntitlement = entitlements.active["pro features"];
    late Subscription subscription;
    if (proEntitlement != null) {
      final activeTill = DateTime.parse(proEntitlement.expirationDate!);
      subscription = Subscription.pro(
        originalAppUserId,
        activeTill,
        proEntitlement.productIdentifier == "rc_promo_pro features_custom",
        managementURL,
      );
    } else {
      subscription = Subscription.free(originalAppUserId);
    }

    return subscription;
  }
}
