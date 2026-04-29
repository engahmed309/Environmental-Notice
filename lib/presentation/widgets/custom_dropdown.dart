import 'package:flutter/material.dart';
import 'package:env_report_app/constants/constants.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final String? hintText;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enableSearch;
  final String? searchHintText;

  const CustomDropdown({
    super.key,
    required this.label,
    this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
    this.isRequired = true,
    this.validator,
    this.prefixIcon,
    this.enableSearch = false,
    this.searchHintText,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

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
                text: widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.isRequired)
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
        if (!widget.enableSearch)
          // Dropdown (classic)
          DropdownButtonFormField<String>(
            focusNode: _focusNode,
            initialValue: widget.value,
            onChanged: widget.onChanged,
            validator: widget.validator,
            items: widget.items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
                borderSide: const BorderSide(
                  color: AppColors.borderColorFocused,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              filled: _isFocused,
              fillColor: _isFocused ? AppColors.background : AppColors.white,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          )
        else
          // Dropdown (searchable)
          FormField<String?>(
            initialValue: widget.value,
            validator: widget.validator,
            builder: (field) {
              final selected = field.value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  _focusNode.requestFocus();
                  final result = await _showSearchDialog(
                    context: context,
                    items: widget.items,
                    selected: selected,
                  );

                  // Only update if user picked an item.
                  // If dialog dismissed (result == null), keep current selection.
                  if (result != null && result != selected) {
                    field.didChange(result);
                    widget.onChanged(result);
                  }

                  if (mounted) _focusNode.unfocus();
                },
                child: InputDecorator(
                  isEmpty: selected == null || selected.isEmpty,
                  isFocused: _isFocused,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: widget.prefixIcon,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusMedium,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.borderColorFocused,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingMedium,
                    ),
                    filled: _isFocused,
                    fillColor:
                        _isFocused ? AppColors.background : AppColors.white,
                  ),
                  child: selected == null
                      ? const SizedBox.shrink()
                      : Text(
                          selected,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<String?> _showSearchDialog({
    required BuildContext context,
    required List<String> items,
    required String? selected,
  }) async {
    final searchController = TextEditingController();

    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(widget.label),
            contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final query =
                      searchController.text.trim().toLowerCase();
                  final filtered = query.isEmpty
                      ? items
                      : items
                          .where(
                            (item) =>
                                item.toLowerCase().contains(query),
                          )
                          .toList();

                  return Column(
                    children: [
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: widget.searchHintText ?? 'ابحث...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (context, _) => const Divider(
                                  height: 1,
                                  thickness: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected = item == selected;
                                  return ListTile(
                                    title: Text(item),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: AppColors.primary,
                                          )
                                        : null,
                                    onTap: () =>
                                        Navigator.of(context).pop(item),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

      return result;
    } finally {
      searchController.dispose();
    }
  }
}
