import 'package:flutter/foundation.dart';

// Only import dart:html on web
// ignore: uri_does_not_exist
import 'dart:html' if (dart.library.io) 'dart:html' as web_html;

class AppConstants {
  // Padding & Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Text Field
  static const int phoneLength = 9; // For Saudi numbers without country code
  static const int notesMaxLength = 500;

  // Image
  static const double imagePickerHeight = 250.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // API
  // Returns the API base URL. On web, if a <meta name="api-base-url"> is present
  // in index.html its content will be used (allows Vercel to inject the final URL).
  static String get apiBaseUrl {
    const fallback = 'https://park.syadtech.com:9100/';
    if (kIsWeb) {
      try {
        final meta = web_html.document.querySelector(
          'meta[name="api-base-url"]',
        );
        final content = meta?.getAttribute('content');
        if (content != null && content.isNotEmpty) return content;
      } catch (_) {}
    }
    return fallback;
  }
}
