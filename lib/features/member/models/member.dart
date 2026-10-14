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
