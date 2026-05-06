import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../data/customer_feedback_submit_service.dart';

final customerFeedbackSubmitServiceProvider =
    Provider<CustomerFeedbackSubmitService>((ref) {
  return CustomerFeedbackSubmitService(ref.watch(firebaseFunctionsProvider));
});
