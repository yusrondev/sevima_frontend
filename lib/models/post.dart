import 'user.dart';
import 'comment.dart';

class Post {
  final int id;
  final int userId;
  final String? caption;
  final String? image;
  final DateTime createdAt;
  final User? user;

  int likesCount;
  bool isLiked;
  final int? commentsCount;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    this.caption,
    this.image,
    required this.createdAt,
    this.user,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final likes = json['likes'] as List? ?? [];

    return Post(
      id: json['id'],
      userId: json['user_id'],
      caption: json['caption'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      likesCount: json['likes_count'] ?? likes.length,
      isLiked: likes.any((like) => like['user_id'] == json['auth_user_id']),
      commentsCount: json['comments_count'] ?? (json['comments'] as List?)?.length ?? 0,
      comments: (json['comments'] as List?)?.map((e) => Comment.fromJson(e)).toList() ?? [],
    );
  }

  String? get imageUrl {
    if (image == null) return null;
    return '$image';
  }
}
