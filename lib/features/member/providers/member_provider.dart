import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/member_data_provider.dart';
import '../models/member.dart';

final memberProvider = Provider<Member?>(
  (ref) => ref.watch(memberDataProvider).value?.member,
);
