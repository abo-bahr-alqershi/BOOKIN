// lib/features/admin_availability_pricing/presentation/widgets/bulk_update_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/availability/availability_bloc.dart';
import '../bloc/pricing/pricing_bloc.dart';
import '../pages/availability_pricing_page.dart';
import '../../domain/entities/availability.dart';
import '../../domain/entities/pricing.dart';

class BulkUpdateDialog extends StatefulWidget {
  final ViewMode viewMode;
  final String unitId;

  const BulkUpdateDialog({
    super.key,
    required this.viewMode,
    required this.unitId,
  });

  static Future<void> show(
    BuildContext context, {
    required ViewMode viewMode,
    required String unitId,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.overlayDark,
      builder: (context) => BulkUpdateDialog(
        viewMode: viewMode,
        unitId: unitId,
      ),
    );
  }

  @override
  State<BulkUpdateDialog> createState() => _BulkUpdateDialogState();
}

class _BulkUpdateDialogState extends State<BulkUpdateDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Availability fields
  AvailabilityStatus? _availabilityStatus;
  String? _reason;
  String? _notes;
  
  // Pricing fields
  double? _price;
  PricingTier? _pricingTier;
  PriceType? _priceType;
  double? _percentageChange;
  
  bool _overwriteExisting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 500,
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.95),
                      AppTheme.darkCard.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.2 + 0.1 * _glowAnimation.value),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2 * _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: _buildFormContent(),
                            ),
                          ),
                        ),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.viewMode == ViewMode.availability
                  ? Icons.event_available_rounded
                  : Icons.attach_money_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.viewMode == ViewMode.availability
                      ? 'تحديث الإتاحة المجمع'
                      : 'تحديث التسعير المجمع',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'قم بتحديث فترة كاملة بنقرة واحدة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateRangeSelector(),
        const SizedBox(height: 24),
        
        if (widget.viewMode == ViewMode.availability)
          _buildAvailabilityFields()
        else
          _buildPricingFields(),
        
        const SizedBox(height: 24),
        _buildOverwriteOption(),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفترة الزمنية',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'من تاريخ',
                value: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'إلى تاريخ',
                value: _endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.6),
              AppTheme.darkSurface.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    value != null
                        ? DateFormat('dd/MM/yyyy').format(value)
                        : 'اختر التاريخ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: value != null ? AppTheme.textWhite : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة الإتاحة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusSelector(),
        
        if (_availabilityStatus == AvailabilityStatus.unavailable ||
            _availabilityStatus == AvailabilityStatus.blocked) ...[
          const SizedBox(height: 16),
          _buildReasonField(),
        ],
        
        const SizedBox(height: 16),
        _buildNotesField(),
      ],
    );
  }

  Widget _buildStatusSelector() {
    final statuses = [
      (AvailabilityStatus.available, 'متاح', AppTheme.success),
      (AvailabilityStatus.unavailable, 'غير متاح', AppTheme.textMuted),
      (AvailabilityStatus.blocked, 'محظور', AppTheme.error),
      (AvailabilityStatus.maintenance, 'صيانة', AppTheme.info),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((item) {
        final isSelected = _availabilityStatus == item.$1;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _availabilityStatus = item.$1;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        item.$3.withOpacity(0.3),
                        item.$3.withOpacity(0.1),
                      ],
                    )
                  : null,
              color: !isSelected ? AppTheme.darkSurface.withOpacity(0.5) : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? item.$3 : AppTheme.darkBorder.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              item.$2,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? item.$3 : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceInput(),
        const SizedBox(height: 16),
        _buildPricingTierSelector(),
        const SizedBox(height: 16),
        _buildPriceTypeSelector(),
        const SizedBox(height: 16),
        _buildPercentageChangeInput(),
      ],
    );
  }

  Widget _buildPriceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السعر',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: 'أدخل السعر',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.attach_money_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            suffixText: 'ريال',
            suffixStyle: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
            filled: true,
            fillColor: AppTheme.darkSurface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
          ),
          onChanged: (value) {
            _price = double.tryParse(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'السعر مطلوب';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricingTierSelector() {
    final tiers = [
      (PricingTier.discount, 'خصم', AppTheme.success),
      (PricingTier.normal, 'عادي', AppTheme.primaryBlue),
      (PricingTier.high, 'مرتفع', AppTheme.warning),
      (PricingTier.peak, 'ذروة', AppTheme.error),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى التسعير',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tiers.map((item) {
            final isSelected = _pricingTier == item.$1;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _pricingTier = item.$1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            item.$3.withOpacity(0.3),
                            item.$3.withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: !isSelected ? AppTheme.darkSurface.withOpacity(0.5) : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? item.$3 : AppTheme.darkBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  item.$2,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? item.$3 : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceTypeSelector() {
    final types = [
      (PriceType.base, 'أساسي'),
      (PriceType.weekend, 'نهاية الأسبوع'),
      (PriceType.seasonal, 'موسمي'),
      (PriceType.holiday, 'عطلة'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع السعر',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PriceType>(
          value: _priceType,
          dropdownColor: AppTheme.darkCard,
          style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.darkSurface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
          ),
          items: types.map((item) {
            return DropdownMenuItem(
              value: item.$1,
              child: Text(item.$2),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _priceType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPercentageChangeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نسبة التغيير (اختياري)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
          decoration: InputDecoration(
            hintText: 'مثال: +20 أو -15',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.percent_rounded,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
            suffixText: '%',
            suffixStyle: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
            filled: true,
            fillColor: AppTheme.darkSurface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryPurple.withOpacity(0.5),
              ),
            ),
          ),
          onChanged: (value) {
            _percentageChange = double.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: 'السبب',
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppTheme.textMuted),
        hintText: 'أدخل سبب عدم الإتاحة',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textMuted.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppTheme.darkSurface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.5),
          ),
        ),
      ),
      onChanged: (value) {
        _reason = value;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      maxLines: 3,
      style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: 'ملاحظات',
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppTheme.textMuted),
        hintText: 'أضف أي ملاحظات إضافية',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textMuted.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AppTheme.darkSurface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.5),
          ),
        ),
      ),
      onChanged: (value) {
        _notes = value;
      },
    );
  }

  Widget _buildOverwriteOption() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استبدال البيانات الموجودة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'سيتم استبدال أي بيانات موجودة في هذه الفترة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _overwriteExisting,
            onChanged: (value) {
              setState(() {
                _overwriteExisting = value;
              });
            },
            activeColor: AppTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isLoading ? null : _handleSubmit,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? LinearGradient(
                          colors: [
                            AppTheme.textMuted.withOpacity(0.3),
                            AppTheme.textMuted.withOpacity(0.2),
                          ],
                        )
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isLoading
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'تطبيق التحديثات',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        // Show error
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // Submit based on view mode
      if (widget.viewMode == ViewMode.availability) {
        // Submit availability update
        // context.read<AvailabilityBloc>().add(BulkUpdateAvailability(...));
      } else {
        // Submit pricing update
        // context.read<PricingBloc>().add(BulkUpdatePricing(...));
      }
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}