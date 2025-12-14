import 'package:aiSeaSafe/utils/constants/enums/app_enums.dart';
import 'package:flutter/services.dart';

class MediaInfo {
  final MediaType? type;
  final String? url;

  // Using only for video thumbnail
  final Uint8List? bytes;

  const MediaInfo({this.type, this.url, this.bytes});

  factory MediaInfo.fromMap(Map<String, dynamic> map) {
    return MediaInfo(type: MediaType.fromName(map['type']), url: map['url']);
  }

  Map<String, dynamic> toMap() {
    return {'type': type?.name, 'url': url};
  }

  bool get isImage => type == MediaType.image;

  bool get isVideo => type == MediaType.video;

  bool get isNetworkUrl => url?.startsWith('https') ?? false;
}
