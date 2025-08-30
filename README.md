# 🚀 Polynot AI Partner - Flutter App

A comprehensive language learning application that combines AI-powered conversation partners with intelligent vocabulary generation and management.

## ✨ Features

### 🎯 **Core Functionality**
- **AI Chat Partners**: Have conversations with AI partners for language practice
- **Vocabulary Generation**: Generate vocabulary lists, phrasal verbs, and idioms
- **Vocabulary Management**: Save, organize, and track your vocabulary learning
- **User Authentication**: Secure user registration and login system
- **Progress Tracking**: Monitor your learning progress and statistics

### 📚 **Vocabulary Features**
- **Smart Generation**: Generate vocabulary by topic, category, or multiple topics
- **Selective Saving**: Choose which vocabulary items to save to your personal list
- **Advanced Filtering**: Filter by level, category, favorites, and search terms
- **User Interactions**: Mark favorites, add notes, rate difficulty, track reviews
- **Personal Lists**: Create custom vocabulary lists for different purposes

### 🎨 **User Experience**
- **Modern UI**: Beautiful Material Design 3 interface
- **Responsive Design**: Works seamlessly across different screen sizes
- **Real-time Feedback**: Instant feedback for all user actions
- **Error Handling**: Comprehensive error handling with retry options
- **Loading States**: Clear loading indicators for all operations

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8.0+
- **State Management**: Provider pattern
- **HTTP Client**: http package
- **Environment Management**: flutter_dotenv
- **UI**: Material Design 3

## 📋 Prerequisites

- Flutter SDK 3.8.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Backend APIs running (see API endpoints below)

## 🚀 Setup Instructions

### 1. **Clone the Repository**
```bash
git clone <repository-url>
cd polynot_aipartner
```

### 2. **Environment Configuration**
Copy the example environment file and configure your API endpoints:
```bash
cp env.example .env
```

Edit `.env` with your API endpoints:
```env
# API Configuration
VOCAB_API_BASE_URL=http://localhost:8001
LOCAL_API_ENDPOINT=http://localhost:8000

# Debug Configuration
VOCAB_DEBUG=true
USE_VOCAB_MOCK=false

# App Configuration
APP_NAME=Polynot AI Partner
APP_VERSION=1.0.0
```

### 3. **Install Dependencies**
```bash
flutter pub get
```

### 4. **Run the App**
```bash
flutter run
```

## 🔌 API Integration Status

### ✅ **Working Endpoints (Ready for Production)**

#### **Generation Endpoints**
- `POST /generate/single` - Generate vocabulary for a single topic
- `POST /generate/multiple` - Generate vocabulary for multiple topics
- `POST /generate/category` - Generate vocabulary by category

#### **Save Endpoint**
- `POST /vocab/save` - Save individual vocabulary entries

#### **List View Endpoint**
- `GET /vocab/list` - Get paginated vocabulary with filtering

#### **Basic Endpoints**
- `GET /categories` - Get available categories
- `GET /topics` - Get available topics
- `GET /vocab/lists` - Get vocabulary lists

### ❌ **Endpoints Requiring Auth Setup**
- `POST /vocab/favorite` - Toggle favorite status
- `POST /vocab/hide` - Hide vocabulary items
- `POST /vocab/note` - Add personal notes
- `POST /vocab/rate` - Rate difficulty
- `POST /vocab/review` - Mark as reviewed
- `POST /vocab/lists` - Create custom lists

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart            # User-related models
│   ├── vocabulary_item.dart # Vocabulary item model
│   ├── vocabulary_category.dart # Category and request models
│   └── ...
├── providers/               # State management
│   ├── user_provider.dart   # User state management
│   └── vocabulary_provider.dart # Vocabulary state management
├── services/               # API services
│   ├── user_service.dart   # User API integration
│   ├── vocabulary_service.dart # Vocabulary API integration
│   └── ...
├── screens/                # UI screens
│   ├── home_screen.dart    # Main home screen
│   ├── vocabulary_generation_screen.dart # Vocabulary generation
│   ├── vocabulary_result_screen.dart # Generation results
│   ├── vocabulary_list_screen.dart # Saved vocabulary list
│   └── ...
├── widgets/                # Reusable UI components
│   ├── vocabulary_generation_card.dart # Generation result cards
│   ├── vocabulary_interaction_card.dart # Interactive vocabulary cards
│   └── ...
└── utils/                  # Utility functions
    ├── app_utils.dart      # Common app utilities
    └── string_extensions.dart # String helper functions
```

## 🎯 Key Features Implementation

### **Vocabulary Generation Workflow**
1. User selects generation mode (single/multiple topics)
2. Configures language, level, and topic settings
3. App calls generation API with proper error handling
4. Results displayed with save functionality for logged-in users
5. Users can selectively save vocabulary items

### **Vocabulary Management**
1. Saved vocabulary displayed in paginated list
2. Advanced filtering by level, category, favorites, etc.
3. User interactions (favorite, hide, rate, review)
4. Personal notes and custom lists
5. Progress tracking and statistics

### **Error Handling & User Feedback**
- Comprehensive error handling with retry options
- Loading states for all async operations
- User-friendly error messages
- Automatic retry mechanisms
- Graceful fallbacks for API failures

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

### **Test Coverage**
- API integration tests
- Widget tests
- Provider state management tests
- User authentication tests
- Vocabulary functionality tests

## 🔧 Development

### **Code Style**
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

### **State Management**
- Use Provider pattern for state management
- Keep providers focused and single-purpose
- Handle loading and error states properly
- Notify listeners appropriately

### **API Integration**
- Use proper error handling for all API calls
- Implement timeout handling
- Add retry mechanisms where appropriate
- Log API interactions for debugging

## 🚀 Deployment

### **Android**
```bash
flutter build apk --release
```

### **iOS**
```bash
flutter build ios --release
```

### **Web**
```bash
flutter build web --release
```

## 📊 Performance Optimizations

- **Lazy Loading**: Vocabulary lists load on demand
- **Pagination**: Efficient handling of large datasets
- **Caching**: Smart caching of API responses
- **Memory Management**: Proper disposal of resources
- **Image Optimization**: Optimized asset loading

## 🔒 Security Considerations

- **Environment Variables**: Sensitive data stored in .env
- **Input Validation**: All user inputs validated
- **Error Handling**: No sensitive data exposed in errors
- **API Security**: Proper authentication headers
- **Data Sanitization**: All data sanitized before processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the test files for usage examples

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Status**: Production Ready ✅
