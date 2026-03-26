import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageHelper {
  static Widget loadNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double radius = 0,
    String? fallbackAsset = 'assets/images/trip_placeholder.png', // Default fallback
  }) {
    // If URL is empty or invalid, show fallback
    if (url.isEmpty || !url.startsWith('http')) {
      return _buildFallback(width, height, radius, fallbackAsset);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildFallback(width, height, radius, fallbackAsset),
      ),
    );
  }

  static Widget loadAvatar(
    String url, {
    double radius = 24,
    VoidCallback? onTap,
  }) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: (url.isNotEmpty && url.startsWith('http'))
          ? CachedNetworkImageProvider(url)
          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
      onBackgroundImageError: (exception, stackTrace) {
        // Fallback handled by backgroundImage logic or default provider behavior
      },
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatar,
      );
    }
    return avatar;
  }

  static Widget _buildFallback(double? width, double? height, double radius, String? asset) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: asset != null
            ? Image.asset(asset, fit: BoxFit.cover, width: width, height: height,
                errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.grey);
              })
            : const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
