import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';

class FeaturesTagsWidget extends StatefulWidget {
  final Function(String) onFeaturesChanged;
  final List<String>? initialFeatures;

  const FeaturesTagsWidget({
    super.key,
    required this.onFeaturesChanged,
    this.initialFeatures,
  });

  @override
  State<FeaturesTagsWidget> createState() => _FeaturesTagsWidgetState();
}

class _FeaturesTagsWidgetState extends State<FeaturesTagsWidget> {
  final _textController = TextEditingController();
  final List<String> _features = [];
  
  final List<String> _suggestions = [
    'واي فاي مجاني',
    'مكيف هواء',
    'تلفزيون ذكي',
    'مطبخ مجهز',
    'شرفة خاصة',
    'موقف سيارة',
    'مسبح',
    'جيم',
    'خدمة تنظيف',
    'أمن وحراسة',
    'خدمة استقبال',
    'صالة ألعاب',
    'منطقة شواء',
    'حديقة خاصة',
    'جاكوزي',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialFeatures != null) {
      _features.addAll(widget.initialFeatures!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addFeature(String feature) {
    if (feature.isNotEmpty && !_features.contains(feature)) {
      setState(() {
        _features.add(feature);
        _textController.clear();
      });
      _updateFeatures();
    }
  }

  void _removeFeature(String feature) {
    setState(() {
      _features.remove(feature);
    });
    _updateFeatures();
  }

  void _updateFeatures() {
    widget.onFeaturesChanged(_features.join(','));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.05),
            AppTheme.primaryBlue.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                size: 20,
                color: AppTheme.primaryPurple,
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                'الميزات المخصصة',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildInputField(),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildFeaturesList(),
          const SizedBox(height: AppDimensions.spaceMedium),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
              decoration: InputDecoration(
                hintText: 'أضف ميزة جديدة...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
              ),
              onSubmitted: _addFeature,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _addFeature(_textController.text);
            },
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppDimensions.radiusMedium),
                  bottomRight: Radius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    if (_features.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Center(
          child: Text(
            'لم تتم إضافة أي ميزات بعد',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppDimensions.spaceSmall,
      runSpacing: AppDimensions.spaceSmall,
      children: _features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.2),
                AppTheme.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✨',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: AppDimensions.spaceXSmall),
              Text(
                feature,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceXSmall),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _removeFeature(feature);
                },
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: AppTheme.textMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuggestions() {
    final availableSuggestions = _suggestions
        .where((s) => !_features.contains(s))
        .toList();

    if (availableSuggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اقتراحات',
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSmall),
        Wrap(
          spacing: AppDimensions.spaceXSmall,
          runSpacing: AppDimensions.spaceXSmall,
          children: availableSuggestions.take(5).map((suggestion) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _addFeature(suggestion);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                  vertical: AppDimensions.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color: AppTheme.darkBorder.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 12,
                      color: AppTheme.textMuted.withOpacity(0.7),
                    ),
                    const SizedBox(width: AppDimensions.spaceXSmall),
                    Text(
                      suggestion,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}