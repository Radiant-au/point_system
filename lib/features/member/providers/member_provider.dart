import 'package:flutter_riverpod/flutter_riverpod.dart';

class Member {
  const Member({
    required this.name,
    required this.phone,
    required this.id,
    required this.type,
  });

  final String name;
  final String phone;
  final String id;
  final String type;

  String get formattedId => id
      .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
      .trim();
}

// Home, Profile, and Member Card all read the same demo member.
final memberProvider = Provider<Member>(
  (ref) => const Member(
    name: 'Tint Zaw Htun',
    phone: '+959 780 131 914',
    id: '1900190000956102',
    type: 'Platinum',
  ),
);
