import 'package:flutter/material.dart';
import 'package:env_report_app/constants/constants.dart';
import 'package:env_report_app/presentation/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSubmitReportPressed;

  const HomeScreen({super.key, required this.onSubmitReportPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: AnimatedPage(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.primary),
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'appLogo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      AppStrings.homeTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      AppStrings.appSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.accentGreen.withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: AppConstants.iconSizeMedium,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Text(
                              AppStrings.homeDescription,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    // Mission Statement
                    Text(
                      'مهمتنا',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildMissionItem(
                      icon: Icons.shield_outlined,
                      title: 'الحماية البيئية',
                      description:
                          'حماية الثروة النباتية والحياة الفطرية في المملكة',
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildMissionItem(
                      icon: Icons.people_outline,
                      title: 'المشاركة المجتمعية',
                      description: 'تفعيل دور المجتمع في الحفاظ على البيئة',
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildMissionItem(
                      icon: Icons.check_circle_outline,
                      title: 'الفعالية والشفافية',
                      description: 'إجراءات سريعة وفعالة على جميع البلاغات',
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    // Submit Button
                    CustomButton(
                      label: AppStrings.submitReportButton,
                      onPressed: onSubmitReportPressed,
                      icon: Icons.add_circle_outline,
                      width: double.infinity,
                      height: 56,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppConstants.iconSizeMedium,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
