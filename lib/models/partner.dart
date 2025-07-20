import 'package:uuid/uuid.dart';

class Partner{
  final String id;
  final String name;
  final String role;
  final String description;
  // final String threadId;

  Partner({
    String? id,
    required this.name,
    required this.role,
    required this.description,
  }) : id = id ?? const Uuid().v4();
}