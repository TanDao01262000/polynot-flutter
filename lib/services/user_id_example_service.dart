import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'social_service.dart';

/// Example service demonstrating the new user_id based endpoints
/// This shows how to properly implement the updated social features
class UserIdExampleService {
  static String get baseUrl => dotenv.env['LOCAL_API_ENDPOINT'] ?? 'http://localhost:8000';

  /// Example: Follow a user using user IDs
  static Future<bool> followUserExample(String targetUserId, String followerUserId) async {
    try {
      print('🔄 Following user $targetUserId with follower $followerUserId');
      
      final result = await SocialService.followUser(targetUserId, followerUserId);
      
      if (result['following'] == true) {
        print('✅ Successfully followed user');
        return true;
      } else {
        print('❌ Failed to follow user');
        return false;
      }
    } catch (e) {
      print('❌ Error following user: $e');
      return false;
    }
  }

  /// Example: Unfollow a user using user IDs
  static Future<bool> unfollowUserExample(String targetUserId, String followerUserId) async {
    try {
      print('🔄 Unfollowing user $targetUserId with follower $followerUserId');
      
      final result = await SocialService.unfollowUser(targetUserId, followerUserId);
      
      if (result['following'] == false) {
        print('✅ Successfully unfollowed user');
        return true;
      } else {
        print('❌ Failed to unfollow user');
        return false;
      }
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      return false;
    }
  }

  /// Example: Get user's followers using user ID
  static Future<List<Map<String, dynamic>>> getFollowersExample(String userId) async {
    try {
      print('🔄 Getting followers for user ID: $userId');
      
      final result = await SocialService.getFollowers(userId);
      final followers = List<Map<String, dynamic>>.from(result['followers'] ?? []);
      
      print('✅ Found ${followers.length} followers');
      return followers;
    } catch (e) {
      print('❌ Error getting followers: $e');
      return [];
    }
  }

  /// Example: Get users that a user is following using user ID
  static Future<List<Map<String, dynamic>>> getFollowingExample(String userId) async {
    try {
      print('🔄 Getting following for user ID: $userId');
      
      final result = await SocialService.getFollowing(userId);
      final following = List<Map<String, dynamic>>.from(result['following'] ?? []);
      
      print('✅ Found ${following.length} following');
      return following;
    } catch (e) {
      print('❌ Error getting following: $e');
      return [];
    }
  }

  /// Example: Get user points using user ID
  static Future<Map<String, dynamic>?> getUserPointsExample(String userId) async {
    try {
      print('🔄 Getting points for user ID: $userId');
      
      final result = await SocialService.getUserPoints(userId);
      
      print('✅ Retrieved user points');
      return result;
    } catch (e) {
      print('❌ Error getting user points: $e');
      return null;
    }
  }

  /// Example: Get user's vocabulary for sharing
  static Future<List<Map<String, dynamic>>> getUserVocabularyExample(
    String userId, 
    String viewerUserId
  ) async {
    try {
      print('🔄 Getting vocabulary for user ID: $userId, viewer: $viewerUserId');
      
      final result = await SocialService.getUserVocabulary(userId, viewerUserId);
      final vocabulary = List<Map<String, dynamic>>.from(result['vocabulary'] ?? []);
      
      print('✅ Found ${vocabulary.length} vocabulary items');
      return vocabulary;
    } catch (e) {
      print('❌ Error getting user vocabulary: $e');
      return [];
    }
  }

  /// Example: Get user's learning content
  static Future<Map<String, dynamic>?> getLearningContentExample(
    String userId, 
    String viewerUserId, {
    String contentType = 'all',
  }) async {
    try {
      print('🔄 Getting learning content for user ID: $userId, viewer: $viewerUserId');
      
      final result = await SocialService.getLearningContent(
        userId, 
        viewerUserId, 
        contentType: contentType,
      );
      
      print('✅ Retrieved learning content');
      return result;
    } catch (e) {
      print('❌ Error getting learning content: $e');
      return null;
    }
  }

  /// Example: Save vocabulary word from another user
  static Future<bool> saveVocabularyExample(String vocabEntryId, String userId) async {
    try {
      print('🔄 Saving vocabulary entry: $vocabEntryId for user: $userId');
      
      final result = await SocialService.saveVocabulary(vocabEntryId, userId);
      
      if (result['saved'] == true) {
        print('✅ Successfully saved vocabulary');
        return true;
      } else {
        print('❌ Failed to save vocabulary');
        return false;
      }
    } catch (e) {
      print('❌ Error saving vocabulary: $e');
      return false;
    }
  }

  /// Example: Get leaderboard using user ID
  static Future<List<Map<String, dynamic>>> getLeaderboardExample(String userId) async {
    try {
      print('🔄 Getting leaderboard for user ID: $userId');
      
      final leaderboard = await SocialService.getLeaderboard(userId, limit: 50);
      
      print('✅ Retrieved leaderboard with ${leaderboard.length} entries');
      return leaderboard;
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  /// Example: Complete vocabulary sharing workflow
  static Future<void> vocabularySharingWorkflowExample(
    String targetUserId,
    String viewerUserId,
  ) async {
    try {
      print('🔄 Starting vocabulary sharing workflow...');
      
      // Step 1: Check if viewer is following the target user
      final following = await getFollowingExample(viewerUserId);
      final isFollowing = following.any((user) => user['user_id'] == targetUserId);
      
      if (!isFollowing) {
        print('⚠️ User is not following target user. Following now...');
        await followUserExample(targetUserId, viewerUserId);
      }
      
      // Step 2: Get target user's vocabulary
      final vocabulary = await getUserVocabularyExample(targetUserId, viewerUserId);
      
      if (vocabulary.isEmpty) {
        print('ℹ️ No vocabulary found for this user');
        return;
      }
      
      // Step 3: Display first few vocabulary items
      print('📚 Found vocabulary items:');
      for (int i = 0; i < vocabulary.length && i < 3; i++) {
        final item = vocabulary[i];
        print('  - ${item['word']}: ${item['definition']}');
        
        // Step 4: Save the vocabulary item
        if (item['id'] != null) {
          await saveVocabularyExample(item['id'], viewerUserId);
        }
      }
      
      print('✅ Vocabulary sharing workflow completed');
    } catch (e) {
      print('❌ Error in vocabulary sharing workflow: $e');
    }
  }

  /// Helper method to demonstrate backward compatibility
  static Future<void> backwardCompatibilityExample(String username) async {
    try {
      print('🔄 Demonstrating backward compatibility with username: $username');
      
      // This will still work - it converts username to user_id internally
      final followers = await SocialService.getFollowersByUsername(username);
      print('✅ Retrieved ${followers.length} followers using username');
      
      final points = await SocialService.getUserPointsByUsername(username);
      print('✅ Retrieved user points using username');
      
    } catch (e) {
      print('❌ Error in backward compatibility example: $e');
    }
  }
}

