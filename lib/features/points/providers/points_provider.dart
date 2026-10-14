import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/rewards_provider.dart';

final pointsProvider = Provider<int?>(
  (ref) => ref.watch(rewardsProvider).value?.balance,
);
