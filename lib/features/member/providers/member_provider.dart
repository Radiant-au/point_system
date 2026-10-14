import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/rewards_provider.dart';
import '../models/member.dart';

final memberProvider = Provider<Member?>(
  (ref) => ref.watch(rewardsProvider).value?.member,
);
