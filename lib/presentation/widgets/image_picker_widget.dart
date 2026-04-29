import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:env_report_app/constants/constants.dart';
import 'package:flutter/foundation.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final bool isRequired;

  const ImagePickerWidget({
    super.key,
    this.imagePath,
    required this.onCameraTap,
    required this.onGalleryTap,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppStrings.selectImageLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        // Image Preview or Picker
        if (imagePath != null && imagePath!.isNotEmpty)
          _buildImagePreview()
        else
          _buildImagePickerOptions(context),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          height: AppConstants.imagePickerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            border: Border.all(color: AppColors.borderColor, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            child: Builder(
              builder: (context) {
                final path = imagePath!;
                // Support data-uri, web blob/url and file path
                if (path.startsWith('data:')) {
                  try {
                    final base64Str = path.split(',').last;
                    final bytes = base64Decode(base64Str);
                    return Image.memory(bytes, fit: BoxFit.cover);
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                }
                // Fallback: treat as network URL
                return Image.network(path, fit: BoxFit.cover);
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit, color: AppColors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerOptions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.borderColor,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        color: AppColors.background,
      ),
      child: Column(
        children: [
          Icon(
            Icons.image_outlined,
            size: AppConstants.iconSizeXLarge,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'اختر صورة من المخالفة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Row(
            children: [
              Expanded(
                child: _buildPickerButton(
                  icon: Icons.camera_alt,
                  label: AppStrings.selectImageFromCamera,
                  onTap: onCameraTap,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildPickerButton(
                  icon: Icons.photo_library,
                  label: AppStrings.selectImageFromGallery,
                  onTap: onGalleryTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppConstants.iconSizeLarge,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
