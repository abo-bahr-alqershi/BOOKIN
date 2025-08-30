import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/currency.dart';

class FuturisticCurrencyFormModal extends StatefulWidget {
  final Currency? currency;
  final bool hasDefaultCurrency;
  final Function(Currency) onSave;
  final VoidCallback onCancel;

  const FuturisticCurrencyFormModal({
    super.key,
    this.currency,
    required this.hasDefaultCurrency,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<FuturisticCurrencyFormModal> createState() => 
      _FuturisticCurrencyFormModalState();
}

class _FuturisticCurrencyFormModalState 
    extends State<FuturisticCurrencyFormModal>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _arabicCodeController;
  late TextEditingController _nameController;
  late TextEditingController _arabicNameController;
  late TextEditingController _exchangeRateController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    final currency = widget.currency;
    _codeController = TextEditingController(text: currency?.code ?? '');
    _arabicCodeController = TextEditingController(
      text: currency?.arabicCode ?? '',
    );
    _nameController = TextEditingController(text: currency?.name ?? '');
    _arabicNameController = TextEditingController(
      text: currency?.arabicName ?? '',
    );
    _exchangeRateController = TextEditingController(
      text: currency?.exchangeRate?.toString() ?? '',
    );
    _isDefault = currency?.isDefault ?? false;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _codeController.dispose();
    _arabicCodeController.dispose();
    _nameController.dispose();
    _arabicNameController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.currency != null;
    final canSetDefault = !widget.hasDefaultCurrency || 
                          (isEditing && widget.currency!.isDefault);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: _buildModalContent(isEditing, canSetDefault),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent(bool isEditing, bool canSetDefault) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      child: Stack(
        children: [
          // Background with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkCard.withOpacity(0.9),
                      AppTheme.darkCard.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: _buildForm(isEditing, canSetDefault),
              ),
            ),
          ),

          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isEditing, bool canSetDefault) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isEditing),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildFormFields(),
                  const SizedBox(height: 20),
                  _buildDefaultSwitch(canSetDefault),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'تعديل العملة' : 'إضافة عملة جديدة',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'قم بتحديث بيانات العملة'
                      : 'أدخل بيانات العملة الجديدة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _codeController,
                label: 'كود العملة',
                hint: 'USD',
                icon: Icons.code_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  if (value.length > 3) {
                    return 'الكود يجب أن يكون 3 أحرف فقط';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                  LengthLimitingTextInputFormatter(3),
                ],
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _arabicCodeController,
                label: 'الكود العربي',
                hint: 'دولار',
                icon: Icons.translate_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'اسم العملة (English)',
          hint: 'US Dollar',
          icon: Icons.label_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _arabicNameController,
          label: 'اسم العملة (عربي)',
          hint: 'الدولار الأمريكي',
          icon: Icons.label_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _exchangeRateController,
          label: 'سعر الصرف',
          hint: '1.00',
          icon: Icons.currency_exchange_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !_isDefault,
          validator: (value) {
            if (!_isDefault && (value == null || value.isEmpty)) {
              return 'هذا الحقل مطلوب للعملات غير الافتراضية';
            }
            if (value != null && value.isNotEmpty) {
              final rate = double.tryParse(value);
              if (rate == null || rate <= 0) {
                return 'أدخل قيمة صحيحة';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.3),
            AppTheme.darkSurface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        enabled: enabled,
        style: AppTextStyles.bodyMedium.copyWith(
          color: enabled ? AppTheme.textWhite : AppTheme.textMuted,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted.withOpacity(0.3),
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryBlue,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          errorStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSwitch(bool canSetDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.05),
            AppTheme.primaryPurple.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            color: _isDefault ? AppTheme.warning : AppTheme.textMuted,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عملة افتراضية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تعيين هذه العملة كعملة النظام الافتراضية',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: canSetDefault
                ? (value) {
                    setState(() {
                      _isDefault = value;
                      if (value) {
                        _exchangeRateController.clear();
                      }
                    });
                  }
                : null,
            activeColor: AppTheme.primaryBlue,
            activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.darkBorder.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.5),
            AppTheme.darkSurface.withOpacity(0.3),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCancelButton(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCancel();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
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
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: _handleSave,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.currency != null ? 'تحديث' : 'إضافة',
            style: AppTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      final currency = Currency(
        code: _codeController.text.toUpperCase(),
        arabicCode: _arabicCodeController.text,
        name: _nameController.text,
        arabicName: _arabicNameController.text,
        isDefault: _isDefault,
        exchangeRate: _isDefault
            ? null
            : double.tryParse(_exchangeRateController.text),
        lastUpdated: DateTime.now(),
      );
      
      widget.onSave(currency);
    }
  }
}