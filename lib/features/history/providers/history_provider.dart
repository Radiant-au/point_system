import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/member_data_provider.dart';
import '../models/point_transaction.dart';

final historyProvider = Provider<List<PointTransaction>?>(
  (ref) => ref.watch(memberDataProvider).value?.transactions,
);
