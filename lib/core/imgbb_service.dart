import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Uploads images to ImgBB and returns the direct image URL.
/// Get your free API key at https://api.imgbb.com
class ImgBBService {
  static final ImgBBService instance = ImgBBService._();
  ImgBBService._();

  // ── Replace with your ImgBB API key ─────────────────────────────────────
  // Get it free at https://api.imgbb.com (sign up → API)
  static const String _apiKey = '918d8aa465a6e70b212d0287a0ede934';

  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  final Dio _dio = Dio();

  /// Upload an image file to ImgBB.
  /// Returns the direct image URL on success, throws on failure.
  Future<String> uploadImage(
    File imageFile, {
    String? name,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final formData = FormData.fromMap({
      'key': _apiKey,
      'image': base64Image,
      if (name != null) 'name': name,
    });

    final response = await _dio.post(
      _uploadUrl,
      data: formData,
      onSendProgress: onProgress != null
          ? (sent, total) {
              if (total > 0) onProgress(sent / total);
            }
          : null,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // ImgBB response: data.data.url (direct link)
      final url = data['data']?['url'] as String?;
      if (url != null && url.isNotEmpty) return url;
      throw Exception('ImgBB returned no URL');
    } else {
      throw Exception('ImgBB upload failed: ${response.statusCode}');
    }
  }
}
