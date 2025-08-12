import 'vocabulary_item.dart';

class GenerateResponse {
  final bool success;
  final String message;
  final String method;
  final Map<String, dynamic> details;
  final List<VocabularyItem> generatedVocabulary;
  final int totalGenerated;
  final int newEntriesSaved;
  final int duplicatesFound;

  GenerateResponse({
    required this.success,
    required this.message,
    required this.method,
    required this.details,
    required this.generatedVocabulary,
    required this.totalGenerated,
    required this.newEntriesSaved,
    required this.duplicatesFound,
  });

  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      method: json['method'] ?? '',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      generatedVocabulary: (json['generated_vocabulary'] as List? ?? [])
          .map((item) => VocabularyItem.fromJson(item))
          .toList(),
      totalGenerated: json['total_generated'] ?? 0,
      newEntriesSaved: json['new_entries_saved'] ?? 0,
      duplicatesFound: json['duplicates_found'] ?? 0,
    );
  }
} 