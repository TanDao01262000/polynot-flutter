import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/social_models.dart';

class SocialService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  /// Create a new social post
  static Future<SocialPost> createPost(
    String userId,
    Map<String, dynamic> postData,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/social/posts?user_id=$userId');

      print('📝 Creating post for user ID: $userId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(postData),
      ).timeout(const Duration(seconds: 15));

      print('📝 Create Post Response: ${response.statusCode}');
      print('📝 Create Post Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SocialPost.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      print('📝 Create Post Error: $e');
      rethrow;
    }
  }

  /// Get news feed for a user
  static Future<List<SocialPost>> getNewsFeed(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/feed').replace(
        queryParameters: {
          'user_id': userId,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('📰 News Feed URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📰 News Feed Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = data['posts'] as List<dynamic>;
        return posts.map((json) => SocialPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news feed: ${response.statusCode}');
      }
    } catch (e) {
      print('📰 News Feed Error: $e');
      rethrow;
    }
  }

  /// Toggle like on a post
  static Future<Map<String, dynamic>> toggleLike(
    String postId,
    String userId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/social/posts/$postId/like?user_id=$userId');

      print('❤️ Toggling like for post: $postId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('❤️ Toggle Like Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print('❤️ Toggle Like Error: $e');
      rethrow;
    }
  }

  /// Toggle follow on a user
  static Future<Map<String, dynamic>> toggleFollow(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$targetUserId/follow?user_id=$currentUserId');

      print('👥 Toggling follow for user: $targetUserId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('👥 Toggle Follow Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to toggle follow: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 Toggle Follow Error: $e');
      rethrow;
    }
  }

  /// Get user points and achievements
  static Future<Map<String, dynamic>> getUserPoints(String username) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$username/points');

      print('🏆 Getting user points for: $username');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🏆 User Points Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user points: ${response.statusCode}');
      }
    } catch (e) {
      print('🏆 User Points Error: $e');
      rethrow;
    }
  }

  /// Get leaderboard data
  static Future<List<Map<String, dynamic>>> getLeaderboard(
    String username, {
    int limit = 50,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/leaderboard').replace(
        queryParameters: {
          'user_id': username,
          'limit': limit.toString(),
        },
      );

      print('🏅 Getting leaderboard for: $username');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🏅 Leaderboard Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['entries'] ?? []);
      } else {
        throw Exception('Failed to load leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      print('🏅 Leaderboard Error: $e');
      rethrow;
    }
  }

  /// Add comment to a post
  static Future<PostComment> addComment(
    String postId,
    String username,
    String content,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/social/posts/$postId/comments');

      print('💬 Adding comment to post: $postId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': username,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 10));

      print('💬 Add Comment Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('💬 Add Comment Error: $e');
      rethrow;
    }
  }

  /// Get comments for a post
  static Future<List<PostComment>> getPostComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/posts/$postId/comments').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('💬 Getting comments for post: $postId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('💬 Get Comments Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final comments = data['comments'] as List<dynamic>;
        return comments.map((json) => PostComment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('💬 Get Comments Error: $e');
      rethrow;
    }
  }

  /// Get user's social profile
  static Future<Map<String, dynamic>> getUserSocialProfile(String username) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$username/profile');

      print('👤 Getting social profile for: $username');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('👤 Social Profile Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load social profile: ${response.statusCode}');
      }
    } catch (e) {
      print('👤 Social Profile Error: $e');
      rethrow;
    }
  }

  /// Get user's followers
  static Future<List<Map<String, dynamic>>> getUserFollowers(
    String username, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$username/followers').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('👥 Getting followers for: $username');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('👥 Followers Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['followers'] ?? []);
      } else {
        throw Exception('Failed to load followers: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 Followers Error: $e');
      rethrow;
    }
  }

  /// Get user's following
  static Future<List<Map<String, dynamic>>> getUserFollowing(
    String username, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/social/users/$username/following').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('👥 Getting following for: $username');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('👥 Following Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['following'] ?? []);
      } else {
        throw Exception('Failed to load following: ${response.statusCode}');
      }
    } catch (e) {
      print('👥 Following Error: $e');
      rethrow;
    }
  }
}
