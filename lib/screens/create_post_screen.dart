import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../models/social_models.dart';

class CreatePostScreen extends StatefulWidget {
  final SocialPost? editPost;
  
  const CreatePostScreen({
    super.key,
    this.editPost,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  
  String _selectedPostType = PostTypes.learningTip;
  String _selectedVisibility = PostVisibility.public;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with edit data if editing
    if (widget.editPost != null) {
      _contentController.text = widget.editPost!.content;
      _selectedPostType = widget.editPost!.postType;
      _selectedVisibility = widget.editPost!.visibility;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.isLoggedIn && userProvider.currentUser != null) {
        if (widget.editPost != null) {
          // Editing existing post
          print('📝 EditPostScreen: Editing post ${widget.editPost!.id}');
          await socialProvider.updatePost(
            postId: widget.editPost!.id,
            userName: userProvider.currentUser!.userName,
            content: _contentController.text.trim(),
            visibility: _selectedVisibility,
            metadata: _getMetadataForPostType(),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post updated successfully!'),
                backgroundColor: Color(0xFF27AE60),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate successful post update
          }
        } else {
          // Creating new post
          print('📝 CreatePostScreen: Using user ID: ${userProvider.currentUser!.id}');
          await socialProvider.createPost(
            userId: userProvider.currentUser!.id,
            postType: _selectedPostType,
            content: _contentController.text.trim(),
            language: userProvider.currentUser!.targetLanguage ?? 'English',
            level: userProvider.currentUser!.userLevel,
            metadata: _getMetadataForPostType(),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post shared successfully!'),
                backgroundColor: Color(0xFF27AE60),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate successful post creation
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to create posts'),
              backgroundColor: Color(0xFFE74C3C),
            ),
          );
        }
      }
    } catch (e) {
      print('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share post: ${e.toString()}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMetadataForPostType() {
    switch (_selectedPostType) {
      case PostTypes.learningTip:
        return {'category': 'tip', 'difficulty': 'general'};
      case PostTypes.milestone:
        return {'category': 'milestone', 'type': 'achievement'};
      case PostTypes.achievement:
        return {'category': 'achievement', 'level': 'completed'};
      case PostTypes.challenge:
        return {'category': 'challenge', 'difficulty': 'medium'};
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) {
          return _buildLoginPrompt();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              widget.editPost != null ? 'Edit Post' : 'Share Progress',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _isSubmitting ? null : _submitPost,
                child: Text(
                  widget.editPost != null ? 'Update' : 'Share',
                  style: TextStyle(
                    color: _isSubmitting ? const Color(0xFFBDC3C7) : const Color(0xFF3498DB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post type selection
                  _buildPostTypeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Content section
                  _buildContentSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Visibility section
                  _buildVisibilitySection(),
                  
                  const SizedBox(height: 32),
                  
                  // Submit button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Share Progress',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.share_outlined,
                  size: 64,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Share Your Journey!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login to share your learning progress with the community and inspire others.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login to Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to share?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Column(
            children: [
              _buildPostTypeOption(
                PostTypes.learningTip,
                'Learning Tip',
                'Share a helpful learning strategy',
                Icons.lightbulb_outline,
              ),
              const Divider(height: 24),
              _buildPostTypeOption(
                PostTypes.milestone,
                'Milestone',
                'Share your learning milestones',
                Icons.emoji_events,
              ),
              const Divider(height: 24),
              _buildPostTypeOption(
                PostTypes.achievement,
                'Achievement',
                'Share your achievements',
                Icons.stars,
              ),
              const Divider(height: 24),
              _buildPostTypeOption(
                PostTypes.challenge,
                'Challenge',
                'Share learning challenges',
                Icons.fitness_center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostTypeOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPostType == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPostType = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F4FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3498DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share your thoughts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: TextFormField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'What would you like to share with the community?',
              hintStyle: TextStyle(color: Color(0xFFBDC3C7)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please write something to share';
              }
              if (value.trim().length < 10) {
                return 'Please write at least 10 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who can see this?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Column(
            children: [
              _buildVisibilityOption(
                PostVisibility.public,
                'Public',
                'Everyone can see this post',
                Icons.public,
              ),
              const Divider(height: 24),
              _buildVisibilityOption(
                PostVisibility.friends,
                'Friends Only',
                'Only your friends can see this',
                Icons.people,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedVisibility == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedVisibility = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F4FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3498DB),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.editPost != null ? 'Update Post' : 'Share with Community',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}