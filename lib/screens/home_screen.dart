// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:instaapp_frontend/models/post.dart';
import 'package:instaapp_frontend/widgets/comment_sheet.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../providers/auth_provider.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  List<Post> posts = [];
  bool loading = true;

  void fetch() async {
    final data = await api.fetchPosts();
    setState(() {
      posts = data;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('InstaApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async => fetch(),
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) {
                    final p = posts[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🧍 User Info (Header)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                p.user?.name.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            title: Text(
                              p.user?.name ?? 'Unknown',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              p.createdAt.toLocal().toString().split(' ')[0],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Icon(Icons.more_vert),
                          ),

                          // 🖼️ Image with Rounded Corners
                          if (p.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  p.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          Text('Gagal memuat gambar'),
                                ),
                              ),
                            ),

                          // ❤️ Like & 💬 Comment
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // Like Button and Count
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final updatedLike = await api
                                            .toggleLike(p.id);
                                        setState(() {
                                          p.isLiked = updatedLike;
                                          p.likesCount += updatedLike ? 1 : -1;
                                        });
                                      },
                                      child: Icon(
                                        p.isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            p.isLiked
                                                ? Colors.red
                                                : Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${p.likesCount}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5), // Increased spacing
                                // Comment Button and Count
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.mode_comment_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => CommentSheet(post: p),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  '${p.commentsCount}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ✏️ Caption
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${p.user?.name ?? "User"}: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: p.caption ?? ""),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newPost = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadScreen()),
          );

          if (newPost != null) {
            setState(() {
              posts.insert(0, newPost); // tambahkan post ke atas
            });
          }
        },
      ),
    );
  }
}
