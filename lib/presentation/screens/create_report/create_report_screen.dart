import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:env_report_app/constants/constants.dart';
import 'package:env_report_app/logic/cubit/cubit.dart';
import 'package:env_report_app/presentation/widgets/widgets.dart';

class CreateReportScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const CreateReportScreen({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  late TextEditingController _notesController;
  late TextEditingController _phoneController;
  String? _selectedPark;
  String? _selectedReportType;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _phoneController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ReportCubit>();
      cubit.fetchParks();
      cubit.fetchNotificationTypes();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createReportTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: BlocListener<ReportCubit, ReportState>(
        listener: (context, state) {
          if (state is ReportSuccess) {
            widget.onSuccess();
          } else if (state is ReportValidationError) {
            _showErrorSnackBar(context, state.message);
          } else if (state is ReportError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                final cubit = context.read<ReportCubit>();
                final report = cubit.currentReport;

                return AnimatedPage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      ImagePickerWidget(
                        imagePath: report.imagePath,
                        onCameraTap: () => cubit.pickImageFromCamera(),
                        onGalleryTap: () => cubit.pickImageFromGallery(),
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      // Park Dropdown
                      CustomDropdown(
                        label: AppStrings.parkLabel,
                        hintText: 'اختر المتنزه الوطني',
                        items: cubit.parks
                            .map((p) => p['name'].toString())
                            .toList(),
                        value: _selectedPark,
                        onChanged: (value) {
                          setState(() => _selectedPark = value);
                          final selected = cubit.parks.firstWhere(
                            (p) => p['name'] == value,
                            orElse: () => {},
                          );
                          if (selected.isNotEmpty) {
                            cubit.updatePark(selected['id'].toString());
                          }
                        },
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        enableSearch: true,
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      // Report Type Selector (buttons)
                      Text(
                        AppStrings.reportTypeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: cubit.notificationTypes.map((type) {
                            final name = type['name']?.toString() ?? '';
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: _buildReportTypeButton(
                                  type: name,
                                  description: name,
                                  isSelected: _selectedReportType == name,
                                  onTap: () {
                                    setState(() => _selectedReportType = name);
                                    cubit.updateReportType(
                                      type['id'].toString(),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      // Notes Text Field
                      CustomTextField(
                        label: AppStrings.notesLabel,
                        hintText: 'أدخل الملاحظات والتفاصيل عن المخالفة',
                        controller: _notesController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 4,
                        maxLength: AppConstants.notesMaxLength,
                        onChanged: (value) => cubit.updateNotes(value),
                        prefixIcon: Icon(Icons.note, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      // Phone Text Field
                      CustomTextField(
                        label: AppStrings.phoneLabel,
                        hintText: '05xxxxxxxxx',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (value) => cubit.updatePhone(value),
                        prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppConstants.paddingXLarge),
                      // Submit and Cancel Buttons
                      if (state is ReportSubmitting)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusLarge,
                                ),
                              ),
                            ),
                            onPressed: null,
                            child: const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: AppStrings.cancelButton,
                                onPressed: widget.onCancel,
                                isOutlined: true,
                                backgroundColor: AppColors.primary,
                                textColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            Expanded(
                              child: CustomButton(
                                label: AppStrings.submitButton,
                                onPressed: () => cubit.submitReport(),
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppConstants.paddingLarge),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildReportTypeButton({
    required String type,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected ? AppColors.primary : AppColors.borderColor;
    final borderWidth = isSelected ? 2.0 : 1.0;
    final fillColor = isSelected
        ? AppColors.primary.withAlpha(25)
        : AppColors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        onTap: onTap,
        child: Container(
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: AppConstants.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXSmall),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
