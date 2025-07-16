import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/post.dart';
import '../models/comment.dart';

class CommentSheet extends StatefulWidget {
  final Post post;

  const CommentSheet({super.key, required this.post});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  final ApiService api = ApiService();
  List<Comment> comments = [];
  bool loading = true;

  void fetchComments() async {
    try {
      final result = await api.fetchComments(widget.post.id);
      setState(() {
        comments = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat komentar: $e')),
      );
    }
  }

  void sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;

    final comment = await api.commentPost(
      widget.post.id,
      _commentCtrl.text.trim(),
    );
    setState(() {
      comments.insert(0, comment);
      _commentCtrl.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? Center(child: CircularProgressIndicator())
                        : comments.isEmpty
                            ? Center(child: Text('Belum ada komentar'))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: comments.length,
                                itemBuilder: (_, i) {
                                  final c = comments[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(c.userName[0].toUpperCase()),
                                    ),
                                    title: Text(c.userName),
                                    subtitle: Text(c.text),
                                  );
                                },
                              ),
                  ),
                  Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _commentCtrl,
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => sendComment(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send_rounded, color: Colors.blue),
                          onPressed: sendComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
