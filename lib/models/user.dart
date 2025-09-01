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
    return User(
      id: json['id'],
      userName: json['user_name'],
      userLevel: json['user_level'],
      targetLanguage: json['target_language'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      nativeLanguage: json['native_language'],
      country: json['country'],
      interests: json['interests'],
      proficiencyLevel: json['proficiency_level'],
      bio: json['bio'],
      learningGoals: json['learning_goals'],
      preferredTopics: json['preferred_topics'],
      studyTimePreference: json['study_time_preference'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      totalConversations: json['total_conversations'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
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
  final int streakDays;
  final DateTime lastLogin;

  LoginResponse({
    required this.streakDays,
    required this.lastLogin,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      streakDays: json['streak_days'],
      lastLogin: DateTime.parse(json['last_login']),
    );
  }
}
