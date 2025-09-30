class User {
  final String id;
  final String userName;
  final String userLevel;
  final dynamic targetLanguage; // Can be String or List<String>
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nativeLanguage;
  final String? country;
  final String? interests;
  final String? proficiencyLevel;
  final String? bio;
  final String? learningGoals;
  final String? preferredTopics;
  final String? studyTimePreference;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final int totalConversations;
  final int totalMessages;
  final int streakDays;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.userName,
    required this.userLevel,
    required this.targetLanguage,
    required this.email,
    this.firstName,
    this.lastName,
    this.nativeLanguage,
    this.country,
    this.interests,
    this.proficiencyLevel,
    this.bio,
    this.learningGoals,
    this.preferredTopics,
    this.studyTimePreference,
    this.avatarUrl,
    required this.isActive,
    this.lastLogin,
    required this.totalConversations,
    required this.totalMessages,
    required this.streakDays,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('🔍 User.fromJson: Parsing user data');
    print('🔍 User.fromJson: JSON keys: ${json.keys.toList()}');
    
    // Helper function to safely parse int values
    int _parseInt(dynamic value, int defaultValue, String fieldName) {
      print('🔍 Parsing $fieldName: value=$value, type=${value?.runtimeType}');
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      print('⚠️ $fieldName: unexpected type ${value.runtimeType}, using default');
      return defaultValue;
    }

    try {
      final user = User(
        id: json['id']?.toString() ?? '',
        userName: json['user_name']?.toString() ?? '',
        userLevel: json['user_level']?.toString() ?? '',
        targetLanguage: json['target_language']?.toString(),
        email: json['email']?.toString() ?? '',
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
        nativeLanguage: json['native_language']?.toString(),
        country: json['country']?.toString(),
        interests: json['interests']?.toString(),
        proficiencyLevel: json['proficiency_level']?.toString(),
        bio: json['bio']?.toString(),
        learningGoals: json['learning_goals']?.toString(),
        preferredTopics: json['preferred_topics']?.toString(),
        studyTimePreference: json['study_time_preference']?.toString(),
        avatarUrl: json['avatar_url']?.toString(),
        isActive: json['is_active'] ?? true,
        lastLogin: json['last_login'] != null 
            ? DateTime.parse(json['last_login']) 
            : null,
        totalConversations: _parseInt(json['total_conversations'], 0, 'totalConversations'),
        totalMessages: _parseInt(json['total_messages'], 0, 'totalMessages'),
        streakDays: _parseInt(json['streak_days'], 0, 'streakDays'),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at']) 
            : null,
      );
      print('✅ User.fromJson: User parsed successfully');
      return user;
    } catch (e, stackTrace) {
      print('🔴 User.fromJson ERROR: $e');
      print('🔴 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_level': userLevel,
      'target_language': targetLanguage,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'native_language': nativeLanguage,
      'country': country,
      'interests': interests,
      'proficiency_level': proficiencyLevel,
      'bio': bio,
      'learning_goals': learningGoals,
      'preferred_topics': preferredTopics,
      'study_time_preference': studyTimePreference,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'total_conversations': totalConversations,
      'total_messages': totalMessages,
      'streak_days': streakDays,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to get target language as string
  String get targetLanguageString {
    if (targetLanguage is List) {
      return (targetLanguage as List).join(', ');
    }
    return targetLanguage.toString();
  }

  User copyWith({
    String? id,
    String? userName,
    String? userLevel,
    dynamic targetLanguage,
    String? email,
    String? firstName,
    String? lastName,
    String? nativeLanguage,
    String? country,
    String? interests,
    String? proficiencyLevel,
    String? bio,
    String? learningGoals,
    String? preferredTopics,
    String? studyTimePreference,
    String? avatarUrl,
    bool? isActive,
    DateTime? lastLogin,
    int? totalConversations,
    int? totalMessages,
    int? streakDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userLevel: userLevel ?? this.userLevel,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      country: country ?? this.country,
      interests: interests ?? this.interests,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      bio: bio ?? this.bio,
      learningGoals: learningGoals ?? this.learningGoals,
      preferredTopics: preferredTopics ?? this.preferredTopics,
      studyTimePreference: studyTimePreference ?? this.studyTimePreference,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      totalConversations: totalConversations ?? this.totalConversations,
      totalMessages: totalMessages ?? this.totalMessages,
      streakDays: streakDays ?? this.streakDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserStatistics {
  final int totalConversations;
  final int totalMessages;
  final int streakDays;
  final double averageMessagesPerConversation;
  final DateTime lastLogin;

  UserStatistics({
    required this.totalConversations,
    required this.totalMessages,
    required this.streakDays,
    required this.averageMessagesPerConversation,
    required this.lastLogin,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalConversations: json['total_conversations'],
      totalMessages: json['total_messages'],
      streakDays: json['streak_days'],
      averageMessagesPerConversation: (json['average_messages_per_conversation'] ?? 0.0).toDouble(),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_conversations': totalConversations,
      'total_messages': totalMessages,
      'streak_days': streakDays,
      'average_messages_per_conversation': averageMessagesPerConversation,
      'last_login': lastLogin.toIso8601String(),
    };
  }
}

class UserProfile {
  final User user;
  final UserStatistics statistics;

  UserProfile({
    required this.user,
    required this.statistics,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      user: User.fromJson(json),
      statistics: UserStatistics.fromJson(json['statistics']),
    );
  }
}

class UserRegistrationRequest {
  final String userName;
  final String userLevel;
  final String targetLanguage;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  UserRegistrationRequest({
    required this.userName,
    required this.userLevel,
    required this.targetLanguage,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_level': userLevel,
      'target_language': targetLanguage,
      'email': email,
      'password': password,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
    };
  }
}

class UserProfileUpdateRequest {
  final String? userLevel;
  final String? targetLanguage;
  final String? firstName;
  final String? lastName;

  UserProfileUpdateRequest({
    this.userLevel,
    this.targetLanguage,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (userLevel != null) data['user_level'] = userLevel;
    if (targetLanguage != null) data['target_language'] = targetLanguage;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    
    // Debug: Print the data being sent
    print('UserProfileUpdateRequest data: $data');
    
    return data;
  }
}

class UserLevelUpdateRequest {
  final String userLevel;

  UserLevelUpdateRequest({
    required this.userLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_level': userLevel,
    };
  }
}

class LoginResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime? expiresAt;
  final int streakDays;
  final DateTime lastLogin;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    this.expiresAt,
    required this.streakDays,
    required this.lastLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Parse expires_in safely (can be int or String)
    int expiresIn = 3600; // Default 1 hour
    if (json['expires_in'] != null) {
      if (json['expires_in'] is int) {
        expiresIn = json['expires_in'];
      } else if (json['expires_in'] is String) {
        expiresIn = int.tryParse(json['expires_in']) ?? 3600;
      }
    }
    
    // Parse streak_days safely (can be int or String)
    int streakDays = 0;
    if (json['streak_days'] != null) {
      if (json['streak_days'] is int) {
        streakDays = json['streak_days'];
      } else if (json['streak_days'] is String) {
        streakDays = int.tryParse(json['streak_days']) ?? 0;
      }
    } else if (json['user'] != null && json['user']['streak_days'] != null) {
      if (json['user']['streak_days'] is int) {
        streakDays = json['user']['streak_days'];
      } else if (json['user']['streak_days'] is String) {
        streakDays = int.tryParse(json['user']['streak_days'] as String) ?? 0;
      }
    }
    
    // Helper to parse DateTime from either String or int (Unix timestamp)
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse DateTime from String: $value');
          return null;
        }
      }
      if (value is int) {
        // Unix timestamp (seconds since epoch)
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      print('⚠️ Unexpected DateTime type: ${value.runtimeType}');
      return null;
    }

    return LoginResponse(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'] ?? json['session_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: expiresIn,
      expiresAt: parseDateTime(json['expires_at']),
      streakDays: streakDays,
      lastLogin: parseDateTime(json['last_login']) 
          ?? parseDateTime(json['user']?['last_login'])
          ?? DateTime.now(),
    );
  }

  // For backward compatibility
  String get sessionToken => accessToken;
}
