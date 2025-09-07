import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 🔍 Service Filters Widget
class ServiceFiltersWidget extends StatelessWidget {
  final String? selectedPropertyId;
  final String? selectedPropertyName;
  final Function(String?) onPropertyChanged;
  final VoidCallback onPropertyFieldTap;
  final VoidCallback? onClearProperty;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const ServiceFiltersWidget({
    super.key,
    required this.selectedPropertyId,
    this.selectedPropertyName,
    required this.onPropertyChanged,
    required this.onPropertyFieldTap,
    this.onClearProperty,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Property Selector
              Expanded(
                flex: 2,
                child: _buildPropertySelector(),
              ),
              
              const SizedBox(width: 16),
              
              // Search Field
              Expanded(
                flex: 3,
                child: _buildSearchField(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العقار',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPropertyFieldTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 0.5,
            ),
          ),
            child: Row(
              children: [
                Icon(
                  Icons.home_work_outlined,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedPropertyId == null
                        ? 'اختر العقار'
                        : (selectedPropertyName ?? 'تم اختيار العقار'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selectedPropertyId == null ? AppTheme.textMuted : AppTheme.textWhite,
                    ),
                  ),
                ),
                if (selectedPropertyId != null && onClearProperty != null)
                  GestureDetector(
                    onTap: onClearProperty,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.darkBorder.withOpacity(0.2), width: 0.5),
                      ),
                      child: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.textMuted,
                        size: 16,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.search,
                    color: AppTheme.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البحث',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن خدمة...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppTheme.darkSurface.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                width: 1,
              ),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textMuted,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () => onSearchChanged(''),
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppTheme.textMuted,
                    ),
                  )
                : null,
          ),
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}