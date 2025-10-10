import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/social_models.dart';
import '../providers/social_provider.dart';
import '../widgets/social_post_card.dart';
import '../widgets/comment_card.dart';

class PostDetailScreen extends StatefulWidget {
  final SocialPost post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    await socialProvider.loadComments(widget.post.id);
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    await socialProvider.addComment(widget.post.id, _commentController.text.trim());
    
    _commentController.clear();
    
    // Scroll to bottom to show new comment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF7F8C8D)),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Post card
                  SocialPostCard(
                    post: widget.post,
                    onLike: () {
                      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                      socialProvider.likePost(widget.post.id);
                    },
                    onComment: () {
                      // Focus on comment input
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comments section
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        if (socialProvider.isLoadingComments) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                color: Color(0xFF3498DB),
              ),
            ),
          );
        }

        if (socialProvider.comments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: const Color(0xFFBDC3C7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No comments yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to share your thoughts!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBDC3C7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (${socialProvider.comments.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            ...socialProvider.comments.map((comment) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CommentCard(comment: comment),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _addComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF3498DB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



