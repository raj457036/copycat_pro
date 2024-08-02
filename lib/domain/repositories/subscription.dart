import 'package:copycat_base/common/failure.dart';
import 'package:copycat_base/db/subscription/subscription.dart';

abstract class SubscriptionRepository {
  FailureOr<Subscription?> get({required String userId});
  FailureOr<Subscription?> applyPromoCoupon(String code);
}
