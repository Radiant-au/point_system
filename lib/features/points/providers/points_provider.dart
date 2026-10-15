import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/member_data_provider.dart';

final pointsProvider = Provider<int?>(
  (ref) => ref.watch(memberDataProvider).value?.balance,
);
