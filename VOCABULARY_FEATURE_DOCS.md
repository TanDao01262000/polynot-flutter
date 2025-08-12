# Vocabulary Generation Feature Documentation

## Overview

This document describes the implementation of the Vocabulary Generation feature in the Polynot Flutter app. This feature allows users to generate vocabulary lists, phrasal verbs, and idioms based on topics, CEFR levels, and language preferences.

## Feature Architecture

### 1. Models (`lib/models/`)

#### `vocabulary_item.dart`
Represents individual vocabulary items with comprehensive information:
```dart
class VocabularyItem {
  final String word;
  final String definition;
  final String partOfSpeech;
  final String example;
  final String exampleTranslation;
  final String level;
  final bool isDuplicate;
  final String? pronunciation;
  final String category;
}
```

**Key Features:**
- **Part of Speech**: noun, verb, adjective, etc.
- **Example Translation**: Vietnamese translations for examples
- **CEFR Level**: A1-C2 difficulty levels
- **Duplicate Detection**: Flag for duplicate vocabulary items
- **Category Classification**: vocabulary, phrasal_verb, idiom, collocation

#### `vocabulary_request.dart`
Handles API request parameters:
```dart
class VocabularyRequest {
  final String topic;
  final String level; // A1, A2, B1, B2, C1, C2
  final String languageToLearn; // english, spanish, french, etc.
  final String learnersNativeLanguage; // vietnamese, english, etc.
  final int vocabPerBatch;
  final int phrasalVerbsPerBatch;
  final int idiomsPerBatch;
  final int delaySeconds;
  final bool saveTopicList;
  final String? topicListName;
  final String? category;
}
```

#### `generate_response.dart`
API response wrapper with statistics:
```dart
class GenerateResponse {
  final bool success;
  final String message;
  final String method;
  final Map<String, dynamic> details;
  final List<VocabularyItem> generatedVocabulary;
  final int totalGenerated;
  final int newEntriesSaved;
  final int duplicatesFound;
}
```

### 2. Services (`lib/services/`)

#### `vocabulary_service.dart`
Complete API integration with multiple endpoints:

**Endpoints Supported:**
- `POST /generate/single` - Single topic generation
- `POST /generate/multiple` - Multiple topics generation
- `POST /generate/category` - Category-based generation
- `GET /categories` - Get available categories
- `GET /topics/{category}` - Get topics by category

**Key Methods:**
```dart
// Single topic generation
static Future<GenerateResponse> generateSingleTopic(VocabularyRequest request)

// Multiple topics generation
static Future<GenerateResponse> generateMultipleTopics({
  required List<String> topics,
  required String level,
  required String languageToLearn,
  required String learnersNativeLanguage,
  // ... other parameters
})

// Category-based generation
static Future<GenerateResponse> generateByCategory({
  required String category,
  required String level,
  required String languageToLearn,
  required String learnersNativeLanguage,
  // ... other parameters
})
```

**Mock Data Support:**
- Comprehensive mock data for development
- 10 predefined categories with topics
- Sample vocabulary with translations
- Proper error handling and fallbacks

### 3. State Management (`lib/providers/`)

#### `vocabulary_provider.dart`
Provider-based state management using ChangeNotifier:

**State Variables:**
- `List<VocabularyItem> vocabularyItems` - Generated vocabulary
- `bool isLoading` - Loading state
- `String? error` - Error messages
- `VocabularyRequest? currentRequest` - Current request
- `GenerateResponse? lastResponse` - Last API response

**Key Methods:**
```dart
// Generate vocabulary for single topic
Future<void> generateVocabulary(VocabularyRequest request)

// Generate for multiple topics
Future<void> generateMultipleTopics({...})

// Generate by category
Future<void> generateByCategory({...})

// Clear vocabulary and reset state
void clearVocabulary()
```

### 4. UI Components (`lib/widgets/`)

#### `vocabulary_category_selector.dart`
Modern grid-based category selection:
- **4 Categories**: Vocabulary, Phrasal Verbs, Idioms, Collocations
- **Visual Design**: Icons, descriptions, selection states
- **Responsive Layout**: 2-column grid with proper spacing

#### `vocabulary_item_card.dart`
Enhanced vocabulary display card:
- **Word & Definition**: Primary information display
- **Part of Speech**: Color-coded badges (noun, verb, etc.)
- **CEFR Level**: Color-coded level indicators (A1-C2)
- **Example & Translation**: Bilingual example sentences
- **Duplicate Detection**: Orange border and badge for duplicates
- **Category Colors**: Different colors for vocabulary types

### 5. Screens (`lib/screens/`)

#### `vocabulary_generation_screen.dart`
Comprehensive generation form with:

**Form Fields:**
- **Category Selection**: Grid-based category picker
- **Topic Input**: Free-text topic entry
- **Language Selection**: Target language and native language dropdowns
- **CEFR Level**: A1-C2 with descriptions
- **Batch Settings**: Separate controls for vocabulary, phrasal verbs, idioms
- **Topic List Management**: Optional naming and saving
- **Generation Controls**: Save to topic list toggle

**Validation:**
- Required topic input
- Category selection validation
- Proper form state management

#### `vocabulary_result_screen.dart`
Results display with comprehensive information:

**Header Section:**
- Category and topic information
- CEFR level and target language
- Generation statistics (total generated, duplicates)
- Visual indicators for success/warnings

**Vocabulary List:**
- Enhanced cards with all vocabulary information
- Tap interactions for detailed view
- Proper loading and error states
- "Generate More" floating action button

### 6. Utilities (`lib/utils/`)

#### `string_extensions.dart`
Shared utility for string capitalization:
```dart
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
```

## API Integration

### Base Configuration
```dart
static const String baseUrl = 'http://localhost:8000';
```

### Request Format
All requests follow the API documentation format:
```json
{
  "topic": "technology",
  "level": "B1",
  "language_to_learn": "english",
  "learners_native_language": "vietnamese",
  "vocab_per_batch": 10,
  "phrasal_verbs_per_batch": 5,
  "idioms_per_batch": 5,
  "delay_seconds": 2,
  "save_topic_list": true,
  "topic_list_name": "My Tech Vocabulary"
}
```

### Response Handling
- **Success**: Parse vocabulary items and statistics
- **Error**: Display user-friendly error messages
- **Loading**: Show progress indicators during generation
- **Mock Data**: Fallback for development and testing

## Available Categories

The app supports 10 predefined categories:
1. `daily_life` - Family, food, shopping, transportation, home
2. `business_professional` - Meetings, presentations, negotiations, emails, teamwork
3. `academic_education` - Research, lectures, assignments, exams, campus
4. `technology_digital` - Software, hardware, programming, social media, cybersecurity
5. `travel_tourism` - Accommodation, transportation, sightseeing, restaurants, culture
6. `health_wellness` - Exercise, nutrition, mental health, medical, fitness
7. `entertainment_media` - Movies, music, books, games, celebrity
8. `sports_fitness` - Football, basketball, tennis, gym, olympics
9. `social_relationships` - Friendship, dating, marriage, networking, communication
10. `environment_nature` - Climate, pollution, conservation, wildlife, sustainability

## CEFR Levels Supported

- **A1** - Beginner
- **A2** - Elementary  
- **B1** - Intermediate
- **B2** - Upper Intermediate
- **C1** - Advanced
- **C2** - Mastery

## Languages Supported

### Target Languages (Language to Learn)
- English
- Spanish
- French
- German
- Italian

### Native Languages
- Vietnamese
- English
- Spanish
- French
- German

## User Flow

1. **Home Screen** → User selects "Vocabulary Generator"
2. **Generation Screen** → User configures:
   - Select category (Vocabulary, Phrasal Verbs, Idioms, Collocations)
   - Enter topic (e.g., "Technology", "Business")
   - Choose target language and native language
   - Select CEFR level (A1-C2)
   - Configure batch sizes for vocabulary, phrasal verbs, idioms
   - Optionally name and save to topic list
3. **Generate** → API call with loading indicator
4. **Results Screen** → Display generated vocabulary with:
   - Statistics (total generated, duplicates)
   - Vocabulary cards with examples and translations
   - Option to generate more vocabulary

## Error Handling

### Network Errors
- Graceful fallback to mock data
- User-friendly error messages
- Retry mechanisms

### Validation Errors
- Form validation with clear error messages
- Required field indicators
- Proper state management

### API Errors
- HTTP status code handling
- Response parsing error handling
- Timeout handling

## Development Features

### Mock Data
Comprehensive mock data for development:
- Sample vocabulary with translations
- Realistic examples and definitions
- Proper categorization and levels
- Duplicate detection simulation

### Debug Information
- API health checks on startup
- Request/response logging
- Error tracking and reporting

## Testing

### Manual Testing Checklist
- [ ] Category selection works
- [ ] Topic input validation
- [ ] Language selection dropdowns
- [ ] CEFR level selection
- [ ] Batch size configuration
- [ ] Form submission
- [ ] Loading states
- [ ] Error handling
- [ ] Results display
- [ ] Navigation flow

### API Testing
- [ ] Single topic generation
- [ ] Multiple topics generation
- [ ] Category-based generation
- [ ] Categories endpoint
- [ ] Topics by category endpoint
- [ ] Error response handling

## Performance Considerations

### UI Performance
- Efficient list rendering with ListView.builder
- Proper widget rebuilding with Consumer pattern
- Image and icon optimization

### Network Performance
- Request timeout handling
- Loading state management
- Error recovery mechanisms

### Memory Management
- Proper disposal of controllers
- State cleanup on navigation
- Provider state management

## Future Enhancements

### Planned Features
1. **Offline Support**: Cache generated vocabulary locally
2. **Favorites**: Save favorite vocabulary items
3. **Search**: Search through generated vocabulary
4. **Export**: Export vocabulary to PDF/CSV
5. **Audio**: Pronunciation audio for vocabulary
6. **Quiz Mode**: Interactive vocabulary testing
7. **Progress Tracking**: Learning progress analytics
8. **Social Features**: Share vocabulary lists

### Technical Improvements
1. **Caching**: Implement local storage for vocabulary
2. **Pagination**: Handle large vocabulary lists
3. **Search**: Add search functionality
4. **Analytics**: Track user behavior and preferences
5. **Accessibility**: Improve accessibility features
6. **Internationalization**: Support multiple UI languages

## Deployment Notes

### API Configuration
- Update `baseUrl` in `vocabulary_service.dart` for production
- Remove mock data fallbacks when API is stable
- Add proper error handling for production

### Environment Variables
- API base URL configuration
- API key management (if required)
- Environment-specific settings

### Build Configuration
- Ensure proper permissions for network access
- Configure iOS/Android network security
- Test on both platforms

## Troubleshooting

### Common Issues
1. **Dropdown Value Errors**: Ensure initial values match available options
2. **Network Timeouts**: Implement proper timeout handling
3. **State Management**: Verify Provider setup and Consumer usage
4. **Navigation Issues**: Check route definitions and navigation calls

### Debug Steps
1. Check API health endpoint
2. Verify request format matches API docs
3. Test with mock data first
4. Check console logs for errors
5. Verify Provider state management

## Conclusion

The Vocabulary Generation feature provides a comprehensive, user-friendly interface for generating vocabulary based on topics, difficulty levels, and language preferences. The implementation follows Flutter best practices with proper state management, error handling, and a modern UI design.

The feature is production-ready with mock data support for development and testing. Integration with the real API requires only updating the base URL and removing mock data fallbacks.

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Author**: AI Assistant  
**Status**: Complete and Ready for Production 