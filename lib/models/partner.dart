import 'package:uuid/uuid.dart';

class Partner {
  final String id;
  final String name;
  final String aiRole;
  final String scenario;
  final String targetLanguage;
  final String userLevel;
  final String personality;
  final String background;
  final String communicationStyle;
  final String expertise;
  final String interests;

  Partner({
    String? id,
    required this.name,
    required this.aiRole,
    required this.scenario,
    required this.targetLanguage,
    required this.userLevel,
    required this.personality,
    required this.background,
    required this.communicationStyle,
    required this.expertise,
    required this.interests,
  }) : id = id ?? const Uuid().v4();

  // Factory constructor for creating from API response
  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      name: json['name'],
      aiRole: json['ai_role'],
      scenario: json['scenario'],
      targetLanguage: json['target_language'],
      userLevel: json['user_level'],
      personality: json['personality'],
      background: json['background'],
      communicationStyle: json['communication_style'],
      expertise: json['expertise'],
      interests: json['interests'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ai_role': aiRole,
      'scenario': scenario,
      'target_language': targetLanguage,
      'user_level': userLevel,
      'personality': personality,
      'background': background,
      'communication_style': communicationStyle,
      'expertise': expertise,
      'interests': interests,
    };
  }

  // Legacy getters for backward compatibility
  String get role => aiRole;
  String get description => scenario;
}