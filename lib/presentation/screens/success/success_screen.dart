import 'package:flutter/material.dart';
import 'package:env_report_app/constants/constants.dart';
import 'package:env_report_app/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:env_report_app/logic/cubit/cubit.dart';

class SuccessScreen extends StatefulWidget {
  final String message;
  final VoidCallback onNewReport;
  final VoidCallback onHome;

  const SuccessScreen({
    super.key,
    required this.message,
    required this.onNewReport,
    required this.onHome,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _opacities;
  late final List<Animation<Offset>> _offsets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacities = List.generate(3, (i) {
      final start = 0.15 + i * 0.12;
      final end = start + 0.35;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _offsets = List.generate(3, (i) {
      final start = 0.15 + i * 0.12;
      final end = start + 0.35;
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: AnimatedPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    AppStrings.successTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Backend message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Logo + Copyright with Hero
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'appLogo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '© المركز الوطني لمكافحة التصحر',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Next Steps Section with staggered animations
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الخطوات التالية:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _animatedStep(
                          0,
                          number: '1',
                          title: 'استلام البلاغ',
                          description:
                              'تم استلام بلاغك بنجاح من قبل الفريق المختص',
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _animatedStep(
                          1,
                          number: '2',
                          title: 'المراجعة',
                          description: 'سيتم مراجعة البلاغ والمعلومات المرفقة',
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _animatedStep(
                          2,
                          number: '3',
                          title: 'الإجراء',
                          description:
                              'اتخاذ الإجراءات اللازمة بناءً على البلاغ',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Buttons
                  CustomButton(
                    label: AppStrings.submitNewReportButton,
                    onPressed: _onNewReportPressed,
                    width: double.infinity,
                    height: 56,
                    icon: Icons.add,
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  CustomButton(
                    label: AppStrings.goHomeButton,
                    onPressed: widget.onHome,
                    width: double.infinity,
                    height: 56,
                    isOutlined: true,
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedStep(
    int index, {
    required String number,
    required String title,
    required String description,
  }) {
    return FadeTransition(
      opacity: _opacities[index],
      child: SlideTransition(
        position: _offsets[index],
        child: _buildStepItem(
          number: number,
          title: title,
          description: description,
        ),
      ),
    );
  }

  void _onNewReportPressed() {
    // Reset the cubit from a context that has the provider (this widget)
    try {
      context.read<ReportCubit>().resetForm();
    } catch (_) {}
    widget.onNewReport();
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
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
