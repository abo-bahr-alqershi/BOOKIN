// lib/features/auth/presentation/widgets/ultra_register_form.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import 'password_strength_indicator.dart';
import 'package:bookn_cp_app/injection_container.dart';
import 'package:bookn_cp_app/core/models/paginated_result.dart';
import 'package:bookn_cp_app/features/admin_properties/data/datasources/property_types_remote_datasource.dart'
    as ap_ds_pt_remote;
import 'package:bookn_cp_app/features/admin_properties/data/models/property_type_model.dart'
    as ap_models;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../core/constants/api_constants.dart';
import '../../../../services/location_service.dart' as loc;
import 'package:async/async.dart';
import 'package:bookn_cp_app/features/admin_cities/domain/usecases/get_cities_usecase.dart'
    as ci_uc;

class RegisterForm extends StatefulWidget {
  final Function(
    String name,
    String email,
    String phone,
    String password,
    String passwordConfirmation,
    // Owner/property fields
    String propertyTypeId,
    String propertyName,
    String city,
    String address,
    double? latitude,
    double? longitude,
    String? description,
  ) onSubmit;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Property fields controllers
  final _propertyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _propertyNameFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _latitudeFocusNode = FocusNode();
  final _longitudeFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _showPasswordStrength = false;
  // Removed star rating field
  String _selectedPropertyTypeId = '';
  List<ap_models.PropertyTypeModel> _propertyTypes = const [];
  bool _loadingPropertyTypes = false;
  // Cities dropdown state
  List<String> _cities = const [];
  bool _loadingCities = false;
  String? _selectedCity;
  String? _citiesError;
  // Places autocomplete
  List<_PlaceSuggestion> _addressSuggestions = const [];
  bool _loadingSuggestions = false;
  CancelableOperation? _pendingAutocomplete;
  Timer? _debounce;

  // Google Places Autocomplete session management and race-guards
  final int _autocompleteRequestSeq = 0;
  String _placesSessionToken = _generatePlacesSessionToken();

  late AnimationController _fieldAnimationController;
  late AnimationController _checkboxAnimationController;

  @override
  void initState() {
    super.initState();

    _fieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _checkboxAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _passwordController.addListener(() {
      setState(() {
        _showPasswordStrength = _passwordController.text.isNotEmpty;
      });
    });

    // Add focus listeners for animations
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _phoneFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
    _propertyNameFocusNode.addListener(() => setState(() {}));
    _cityFocusNode.addListener(() => setState(() {}));
    _addressFocusNode.addListener(() => setState(() {}));
    _latitudeFocusNode.addListener(() => setState(() {}));
    _longitudeFocusNode.addListener(() => setState(() {}));

    _loadPropertyTypes();
    _loadCities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _propertyNameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _propertyNameFocusNode.dispose();
    _cityFocusNode.dispose();
    _addressFocusNode.dispose();
    _latitudeFocusNode.dispose();
    _longitudeFocusNode.dispose();
    _fieldAnimationController.dispose();
    _checkboxAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          _buildUltraCompactField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'الاسم',
            hint: 'اسمك الكامل',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (value.length < 3) {
                return '3 أحرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Email field
          _buildUltraCompactField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'البريد',
            hint: 'example@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_phoneFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (!Validators.isValidEmail(value)) {
                return 'بريد غير صحيح';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Phone field
          _buildUltraCompactField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            label: 'الهاتف',
            hint: '967XXXXXXXXX',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (!Validators.isValidPhoneNumber('+$value')) {
                return 'رقم غير صحيح';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Password field
          _buildUltraCompactField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'كلمة المرور',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            },
            suffixIcon: _buildPasswordToggle(
              obscure: _obscurePassword,
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (!Validators.isValidPassword(value, minLength: 8)) {
                return '8 أحرف على الأقل';
              }
              return null;
            },
          ),

          // Password strength indicator
          if (_showPasswordStrength) ...[
            const SizedBox(height: 8),
            PasswordStrengthIndicator(
              password: _passwordController.text,
              showRequirements: false,
            ),
          ],

          const SizedBox(height: 12),

          // Confirm password field
          _buildUltraCompactField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            label: 'تأكيد المرور',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSubmit(),
            suffixIcon: _buildPasswordToggle(
              obscure: _obscureConfirmPassword,
              onTap: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              if (value != _passwordController.text) {
                return 'كلمات المرور غير متطابقة';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Property section header
          _buildSectionHeader('بيانات الكيان'),

          // Property type dropdown
          _buildPropertyTypeDropdown(),

          const SizedBox(height: 12),

          // Property name
          _buildUltraCompactField(
            controller: _propertyNameController,
            focusNode: _propertyNameFocusNode,
            label: 'اسم الكيان',
            hint: 'مثل: فندق الراحة',
            icon: Icons.apartment_rounded,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_cityFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'مطلوب';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // City
          _buildCityDropdown(),

          const SizedBox(height: 12),

          // Address
          _buildUltraCompactField(
            controller: _addressController,
            focusNode: _addressFocusNode,
            onChanged: _onAddressChanged,
            label: 'العنوان',
            hint: 'مثل: الاصبحي شارع المقالح',
            icon: Icons.map_outlined,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_latitudeFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'مطلوب';
              return null;
            },
          ),

          // Address suggestions
          if (_addressSuggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildAddressSuggestionsPanel(),
          ],

          const SizedBox(height: 12),

          // Latitude & Longitude
          Row(
            children: [
              Expanded(
                child: _buildUltraCompactField(
                  controller: _latitudeController,
                  focusNode: _latitudeFocusNode,
                  label: 'خط العرض',
                  hint: 'Latitude',
                  icon: Icons.my_location_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_longitudeFocusNode);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUltraCompactField(
                  controller: _longitudeController,
                  focusNode: _longitudeFocusNode,
                  label: 'خط الطول',
                  hint: 'Longitude',
                  icon: Icons.my_location_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Star rating removed

          // Map picker button
          _buildMapPickerButton(),

          const SizedBox(height: 12),

          // Description (optional)
          _buildUltraTextarea(
            controller: _descriptionController,
            label: 'وصف (اختياري)',
            hint: 'وصف مختصر عن الكيان وخدماته',
            icon: Icons.description_outlined,
          ),

          const SizedBox(height: 16),

          // Terms checkbox
          _buildUltraTermsCheckbox(),

          const SizedBox(height: 20),

          // Submit button
          _buildUltraSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textWhite.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUltraCompactField(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String label,
      required String hint,
      required IconData icon,
      bool obscureText = false,
      TextInputType? keyboardType,
      TextInputAction? textInputAction,
      Widget? suffixIcon,
      List<TextInputFormatter>? inputFormatters,
      Function(String)? onFieldSubmitted,
      String? Function(String?)? validator,
      Function(String)? onChanged}) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFocused
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.primaryPurple.withValues(alpha: 0.03),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.2),
                  AppTheme.darkCard.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isFocused
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            enabled: !widget.isLoading,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite.withValues(alpha: 0.9),
              fontSize: 12,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: AppTextStyles.caption.copyWith(
                color: isFocused
                    ? AppTheme.primaryBlue.withValues(alpha: 0.8)
                    : AppTheme.textMuted.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                fontSize: 11,
              ),
              prefixIcon: Container(
                width: 32,
                height: 42,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: isFocused
                      ? AppTheme.primaryBlue.withValues(alpha: 0.7)
                      : AppTheme.textMuted.withValues(alpha: 0.4),
                  size: 16,
                ),
              ),
              suffixIcon: suffixIcon,
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 12,
                right: 0,
                top: 10,
                bottom: 10,
              ),
              isDense: true,
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }

  Widget _buildMapPickerButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : _openMapPicker,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.8),
                AppTheme.primaryBlue.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'تحديد على الخريطة',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordToggle({
    required bool obscure,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 42,
        alignment: Alignment.center,
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textMuted.withValues(alpha: 0.4),
          size: 14,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    final isFocused = _propertyNameFocusNode.hasFocus; // reuse style cues
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFocused
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.primaryPurple.withValues(alpha: 0.03),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.2),
                  AppTheme.darkCard.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isFocused
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPropertyTypeId.isEmpty
                  ? null
                  : _selectedPropertyTypeId,
              items: _propertyTypes
                  .map((t) => DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(
                          t.name,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textWhite.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: widget.isLoading || _loadingPropertyTypes
                  ? null
                  : (v) {
                      setState(() => _selectedPropertyTypeId = v ?? '');
                    },
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: AppTheme.textMuted.withValues(alpha: 0.4),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _loadingPropertyTypes
                          ? 'جاري تحميل الأنواع...'
                          : 'نوع الكيان',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              isExpanded: true,
              dropdownColor: AppTheme.darkCard,
            ),
          ),
        ),
      ),
    );
  }

  // Star rating picker removed

  Widget _buildUltraTextarea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.2),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite.withValues(alpha: 0.9),
              fontSize: 12,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                fontSize: 11,
              ),
              prefixIcon: Container(
                width: 32,
                alignment: Alignment.topCenter,
                child: Icon(
                  icon,
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                  size: 16,
                ),
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 12,
                right: 0,
                top: 8,
                bottom: 8,
              ),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUltraTermsCheckbox() {
    return GestureDetector(
      onTap: widget.isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
              setState(() {
                _acceptTerms = !_acceptTerms;
                if (_acceptTerms) {
                  _checkboxAnimationController.forward();
                } else {
                  _checkboxAnimationController.reverse();
                }
              });
            },
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              gradient: _acceptTerms ? AppTheme.primaryGradient : null,
              color: !_acceptTerms
                  ? AppTheme.darkCard.withValues(alpha: 0.3)
                  : null,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _acceptTerms
                    ? Colors.transparent
                    : AppTheme.darkBorder.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: _acceptTerms
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'الشروط',
                    style: TextStyle(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      decoration: TextDecoration.underline,
                      decorationColor:
                          AppTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  const TextSpan(text: ' و'),
                  TextSpan(
                    text: 'الخصوصية',
                    style: TextStyle(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      decoration: TextDecoration.underline,
                      decorationColor:
                          AppTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraSubmitButton() {
    final canSubmit = !widget.isLoading;

    return GestureDetector(
      onTap: canSubmit ? _onSubmit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          gradient: canSubmit
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    AppTheme.darkCard.withValues(alpha: 0.3),
                    AppTheme.darkCard.withValues(alpha: 0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canSubmit
                ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                : AppTheme.darkBorder.withValues(alpha: 0.1),
            width: 0.5,
          ),
          boxShadow: canSubmit
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'جاري التسجيل...',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'إنشاء حساب',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_acceptTerms) {
      HapticFeedback.lightImpact();
      _showUltraWarning();
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      HapticFeedback.mediumImpact();

      // Validate property fields minimal requirements
      if (_selectedPropertyTypeId.isEmpty) {
        _showFieldError('نوع الكيان مطلوب');
        return;
      }
      if (_propertyNameController.text.trim().isEmpty) {
        _showFieldError('اسم الكيان مطلوب');
        return;
      }
      if (_cityController.text.trim().isEmpty) {
        _showFieldError('المدينة مطلوبة');
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        _showFieldError('العنوان مطلوب');
        return;
      }

      widget.onSubmit(
        _nameController.text.trim(),
        _emailController.text.trim(),
        '+${_phoneController.text.trim()}',
        _passwordController.text,
        _confirmPasswordController.text,
        _selectedPropertyTypeId,
        _propertyNameController.text.trim(),
        _cityController.text.trim(),
        _addressController.text.trim(),
        _tryParseDouble(_latitudeController.text.trim()),
        _tryParseDouble(_longitudeController.text.trim()),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
    }
  }

  void _showFieldError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  double? _tryParseDouble(String v) {
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }

  void _showUltraWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withValues(alpha: 0.8),
                      AppTheme.warning.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'يجب الموافقة على الشروط',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.darkCard.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadPropertyTypes() async {
    setState(() => _loadingPropertyTypes = true);
    try {
      final ds = sl<ap_ds_pt_remote.PropertyTypesRemoteDataSource>();
      final PaginatedResult<ap_models.PropertyTypeModel> result =
          await ds.getAllPropertyTypes(pageNumber: 1, pageSize: 1000);
      setState(() {
        _propertyTypes = result.items;
      });
    } catch (_) {
      // ignore; dropdown will show empty
    } finally {
      setState(() => _loadingPropertyTypes = false);
    }
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
      _citiesError = null;
    });
    try {
      final usecase = sl<ci_uc.GetCitiesUseCase>();
      final result = await usecase(const ci_uc.GetCitiesParams());
      result.fold(
        (_) => setState(() {
          _citiesError = 'تعذر تحميل المدن';
          _loadingCities = false;
        }),
        (list) => setState(() {
          _cities = list.map((c) => c.name).toList();
          _loadingCities = false;
          // لا نعيّن قيمة تلقائياً لإجبار المستخدم على الاختيار والتصديق
          if (_cities.contains(_cityController.text)) {
            _selectedCity = _cityController.text;
          } else {
            _selectedCity = null;
            _cityController.text = '';
          }
        }),
      );
    } catch (_) {
      setState(() {
        _citiesError = 'تعذر تحميل المدن';
        _loadingCities = false;
      });
    }
  }

  Widget _buildCityDropdown() {
    final isFocused = _cityFocusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFocused
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.primaryPurple.withValues(alpha: 0.03),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.2),
                  AppTheme.darkCard.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isFocused
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String?>(
              value: _cities.contains(_selectedCity) ? _selectedCity : null,
              dropdownColor: AppTheme.darkCard,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textWhite.withValues(alpha: 0.9),
                fontSize: 12,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
              decoration: InputDecoration(
                labelText: 'المدينة',
                labelStyle: AppTextStyles.caption.copyWith(
                  color: isFocused
                      ? AppTheme.primaryBlue.withValues(alpha: 0.8)
                      : AppTheme.textMuted.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
                prefixIcon: Container(
                  width: 32,
                  height: 42,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.location_city_outlined,
                    color: isFocused
                        ? AppTheme.primaryBlue.withValues(alpha: 0.7)
                        : AppTheme.textMuted.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              items: _loadingCities
                  ? [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('جاري تحميل المدن...'),
                      )
                    ]
                  : _cities
                      .map((c) => DropdownMenuItem<String?>(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCity = v;
                  _cityController.text = v ?? '';
                });
              },
              validator: (v) {
                if ((_cityController.text).trim().isEmpty) {
                  return 'المدينة مطلوبة';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  // Places autocomplete
  void _onAddressChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        setState(() => _addressSuggestions = const []);
        return;
      }
      _fetchPlaceAutocomplete(value.trim());
    });
  }

  Future<void> _fetchPlaceAutocomplete(String input) async {
    const apiKey = ApiConstants.googlePlacesApiKey;

    setState(() => _loadingSuggestions = true);

    try {
      final client = dio.Dio();

      // 🆕 استخدم NEW Places API
      final response = await client.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        data: {
          'input': input,
          'languageCode': 'ar',
          'regionCode': 'YE',
        },
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask':
                'suggestions.placePrediction.text,suggestions.placePrediction.placeId',
          },
        ),
      );

      if (response.statusCode == 200) {
        final suggestions = response.data['suggestions'] as List? ?? [];

        setState(() {
          _addressSuggestions = suggestions.map((s) {
            final prediction = s['placePrediction'];
            return _PlaceSuggestion(
              description: prediction?['text']?['text'] ?? '',
              placeId: prediction?['placeId'] ?? '',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      setState(() => _loadingSuggestions = false);
    }
  }

  Widget _buildAddressSuggestionsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: _addressSuggestions
            .map(
              (s) => InkWell(
                onTap: () => _selectPlaceSuggestion(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        color: AppTheme.textMuted.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.description,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textWhite.withValues(alpha: 0.9),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _selectPlaceSuggestion(_PlaceSuggestion s) async {
    _addressController.text = s.description;
    setState(() => _addressSuggestions = const []);
    if (ApiConstants.googlePlacesApiKey.isEmpty) return;
    try {
      final client = dio.Dio();
      final resp = await client.get(
        '${ApiConstants.googlePlacesBaseUrl}/details/json',
        queryParameters: {
          'place_id': s.placeId,
          'key': ApiConstants.googlePlacesApiKey,
          'language': 'ar',
          'sessiontoken': _placesSessionToken,
        },
      );
      final result = resp.data['result'];
      final loc = result['geometry']?['location'];
      if (loc != null) {
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        _latitudeController.text = lat.toStringAsFixed(6);
        _longitudeController.text = lng.toStringAsFixed(6);
        // Try to set city
        final comps = (result['address_components'] as List?) ?? [];
        final cityComp = comps.firstWhere(
          (c) =>
              ((c['types'] as List?) ?? []).contains('locality') ||
              ((c['types'] as List?) ?? [])
                  .contains('administrative_area_level_1'),
          orElse: () => null,
        );
        if (cityComp != null) {
          final cityName = (cityComp['long_name'] ?? '').toString();
          if (cityName.isNotEmpty) {
            _cityController.text = cityName;
          }
        }
      }
    } catch (_) {
      // ignore
    }
    // End the current autocomplete session after a successful selection
    _placesSessionToken = _generatePlacesSessionToken();
  }

  void _openMapPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _RegisterMapPickerDialog(
        initialLocation: _tryParseDouble(_latitudeController.text) != null &&
                _tryParseDouble(_longitudeController.text) != null
            ? LatLng(
                _tryParseDouble(_latitudeController.text)!,
                _tryParseDouble(_longitudeController.text)!,
              )
            : null,
        onLocationSelected: (location, address) async {
          _latitudeController.text = location.latitude.toStringAsFixed(6);
          _longitudeController.text = location.longitude.toStringAsFixed(6);
          if (address != null && address.isNotEmpty) {
            _addressController.text = address;
          } else {
            try {
              final svc = sl<loc.LocationService>();
              final addr = await svc.getAddressFromCoordinates(
                location.latitude,
                location.longitude,
              );
              if (addr != null) {
                _addressController.text = addr.formattedAddress;
                if ((addr.locality ?? '').isNotEmpty) {
                  _cityController.text = addr.locality!;
                }
              }
            } catch (_) {}
          }
          setState(() {});
        },
      ),
    );
  }
}

class _PlaceSuggestion {
  final String description;
  final String placeId;
  _PlaceSuggestion({required this.description, required this.placeId});
}

class _RegisterMapPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String?) onLocationSelected;

  const _RegisterMapPickerDialog({
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_RegisterMapPickerDialog> createState() =>
      _RegisterMapPickerDialogState();
}

class _RegisterMapPickerDialogState extends State<_RegisterMapPickerDialog> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _updateMarker(_selectedLocation!);
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: const MarkerId('selected'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(15.3694, 44.1910),
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  onTap: (location) {
                    _updateMarker(location);
                    _selectedAddress =
                        'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.darkCard,
                          AppTheme.darkCard.withValues(alpha: 0.95),
                          AppTheme.darkCard.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.darkSurface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    AppTheme.darkBorder.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.textWhite,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تحديد الموقع على الخريطة',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.darkCard,
                          AppTheme.darkCard.withValues(alpha: 0.95),
                          AppTheme.darkCard.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.darkSurface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.darkBorder
                                      .withValues(alpha: 0.3),
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
                          child: GestureDetector(
                            onTap: _selectedLocation != null
                                ? () {
                                    widget.onLocationSelected(
                                      _selectedLocation!,
                                      _selectedAddress,
                                    );
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: _selectedLocation != null
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: _selectedLocation == null
                                    ? AppTheme.darkSurface
                                        .withValues(alpha: 0.5)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedLocation != null
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'تأكيد الموقع',
                                  style: AppTextStyles.buttonMedium.copyWith(
                                    color: _selectedLocation != null
                                        ? Colors.white
                                        : AppTheme.textMuted
                                            .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple cancellable op placeholder (no external dep)

// Helpers
String _generatePlacesSessionToken() =>
    'sess_${DateTime.now().microsecondsSinceEpoch}';
