import 'package:flutter/material.dart';

class PhotoLightboxDialog extends StatelessWidget {
  final String imageUrl;
  final String caption;

  const PhotoLightboxDialog({
    super.key,
    required this.imageUrl,
    this.caption = '',
  });

  static void show(BuildContext context, String imageUrl, {String caption = ''}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => PhotoLightboxDialog(imageUrl: imageUrl, caption: caption),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    caption,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
