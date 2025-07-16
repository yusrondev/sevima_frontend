import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/post.dart';
import 'models/comment.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://e21108be3c1a.ngrok-free.app/api'),
  );
  final storage = FlutterSecureStorage();

  Future<void> setAuthToken() async {
    final token = await storage.read(key: 'jwt');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<bool> login(String email, String pwd) async {
    final res = await _dio.post(
      '/login',
      data: {'email': email, 'password': pwd},
    );
    print(res);
    if (res.statusCode == 200) {
      await storage.write(key: 'jwt', value: res.data['token']);
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String pwd, String name) async {
    final res = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': pwd,
        'password_confirmation': pwd,
      },
    );
    return res.statusCode == 201;
  }

  Future<List<Post>> fetchPosts() async {
    await setAuthToken();
    final res = await _dio.get('/posts');
    return (res.data as List).map((e) => Post.fromJson(e)).toList();
  }

  Future<Post> createPost(String caption, File? image) async {
    await setAuthToken();
    final form = FormData();
    form.fields.add(MapEntry('caption', caption));
    if (image != null) {
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }
    final res = await _dio.post('/posts', data: form);
    return Post.fromJson(res.data['post']);
  }

  Future<Comment> commentPost(int postId, String text) async {
    await setAuthToken();
    final res = await _dio.post('/posts/$postId/comment', data: {'text': text});
    return Comment.fromJson(res.data);
  }

  Future<List<Comment>> fetchComments(int postId) async {
    await setAuthToken();
    final res = await _dio.get('/posts/$postId/comments');
    return (res.data as List).map((e) => Comment.fromJson(e)).toList();
  }

  Future<bool> toggleLike(int postId) async {
    await setAuthToken(); // Pastikan token sudah disetel
    try {
      final res = await _dio.post('/posts/$postId/like');
      return res.data['liked'] == true;
    } catch (e) {
      print('Gagal like: $e');
      throw Exception('Gagal menyukai postingan');
    }
  }
}
