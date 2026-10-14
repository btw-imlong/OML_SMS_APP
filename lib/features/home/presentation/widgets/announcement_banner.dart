import 'package:flutter/material.dart';

class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imagePath; // local asset
  final String? imageUrl; // network image

  ImageProvider? get _image {
    if (imagePath != null) return AssetImage(imagePath!);
    if (imageUrl != null) return NetworkImage(imageUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
