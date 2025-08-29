import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../bloc/unit_form/unit_form_bloc.dart';
import '../widgets/unit_form_widget.dart';
import '../widgets/dynamic_fields_widget.dart';
import '../widgets/capacity_selector_widget.dart';
import '../widgets/pricing_form_widget.dart';
import '../widgets/features_tags_widget.dart';

class CreateUnitPage extends StatefulWidget {
  const CreateUnitPage({super.key});

  @override
  State<CreateUnitPage> createState() => _CreateUnitPageState();
}

class _CreateUnitPageState extends State<CreateUnitPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_backgroundAnimationController);

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    ));

    _formAnimationController.forward();
  }

  void _loadInitialData() {
    context.read<UnitFormBloc>().add(InitializeFormEvent());
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
          child: CustomPaint(
            painter: _CreateUnitBackgroundPainter(
              animationValue: _backgroundAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _formFadeAnimation,
              child: SlideTransition(
                position: _formSlideAnimation,
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassLight.withOpacity(0.1),
                  AppTheme.glassDark.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Row(
              children: [
                _buildBackButton(),
                const SizedBox(width: AppDimensions.spaceMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'إضافة وحدة جديدة',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'قم بملء البيانات المطلوبة لإضافة وحدة جديدة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStepIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: AppTheme.textWhite,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: [
          Text(
            'الخطوة',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceXSmall),
          Text(
            '${_currentStep + 1}/4',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return BlocConsumer<UnitFormBloc, UnitFormState>(
      listener: (context, state) {
        if (state is UnitFormSubmitted) {
          _showSuccessDialog();
        } else if (state is UnitFormError) {
          _showErrorDialog(state.message);
        }
      },
      builder: (context, state) {
        if (state is UnitFormLoading) {
          return _buildLoadingState();
        }

        return Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: _handleStepContinue,
            onStepCancel: _handleStepCancel,
            onStepTapped: (step) => setState(() => _currentStep = step),
            controlsBuilder: _buildStepControls,
            steps: [
              _buildBasicInfoStep(state),
              _buildPricingStep(state),
              _buildDynamicFieldsStep(state),
              _buildImagesStep(state),
            ],
          ),
        );
      },
    );
  }

  Step _buildBasicInfoStep(UnitFormState state) {
    return Step(
      title: Text(
        'المعلومات الأساسية',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      content: Column(
        children: [
          UnitFormWidget(
            onPropertyChanged: (propertyId) {
              context.read<UnitFormBloc>().add(
                    PropertySelectedEvent(propertyId: propertyId),
                  );
            },
            onUnitTypeChanged: (unitTypeId) {
              context.read<UnitFormBloc>().add(
                    UnitTypeSelectedEvent(unitTypeId: unitTypeId),
                  );
            },
          ),
          if (state is UnitFormReady && state.selectedUnitType != null)
            CapacitySelectorWidget(
              unitType: state.selectedUnitType!,
              onCapacityChanged: (adults, children) {
                context.read<UnitFormBloc>().add(
                      UpdateCapacityEvent(
                        adultCapacity: adults,
                        childrenCapacity: children,
                      ),
                    );
              },
            ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildPricingStep(UnitFormState state) {
    return Step(
      title: Text(
        'التسعير والميزات',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      content: Column(
        children: [
          PricingFormWidget(
            onPricingChanged: (basePrice, pricingMethod) {
              context.read<UnitFormBloc>().add(
                    UpdatePricingEvent(
                      basePrice: basePrice,
                      pricingMethod: pricingMethod,
                    ),
                  );
            },
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          FeaturesTagsWidget(
            onFeaturesChanged: (features) {
              context.read<UnitFormBloc>().add(
                    UpdateFeaturesEvent(features: features),
                  );
            },
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDynamicFieldsStep(UnitFormState state) {
    return Step(
      title: Text(
        'معلومات إضافية',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      content: state is UnitFormReady && state.unitTypeFields.isNotEmpty
          ? DynamicFieldsWidget(
              fields: state.unitTypeFields,
              values: state.dynamicFieldValues,
              onChanged: (values) {
                context.read<UnitFormBloc>().add(
                      UpdateDynamicFieldsEvent(values: values),
                    );
              },
            )
          : _buildNoFieldsMessage(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildImagesStep(UnitFormState state) {
    return Step(
      title: Text(
        'الصور',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      content: _buildImageUploadSection(),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildNoFieldsMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Center(
        child: Text(
          'لا توجد حقول إضافية لهذا النوع من الوحدات',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload,
            size: 64,
            color: AppTheme.primaryBlue.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'اسحب الصور هنا أو انقر للاختيار',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'يمكنك رفع حتى 10 صور بحجم أقصى 5MB لكل صورة',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spaceLarge),
      child: Row(
        children: [
          if (_currentStep > 0)
            _buildStepButton(
              label: 'السابق',
              onTap: details.onStepCancel!,
              isPrimary: false,
            ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: _buildStepButton(
              label: _currentStep < 3 ? 'التالي' : 'حفظ',
              onTap: details.onStepContinue!,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isPrimary ? Colors.white : AppTheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'جاري الحفظ...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _handleStepContinue() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      if (_formKey.currentState!.validate()) {
        context.read<UnitFormBloc>().add(SubmitFormEvent());
      }
    }
  }

  void _handleStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            border: Border.all(
              color: AppTheme.success.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.success,
                      AppTheme.success.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                'تمت الإضافة بنجاح',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                'تم إضافة الوحدة بنجاح',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              _buildDialogButton(
                label: 'موافق',
                onTap: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            border: Border.all(
              color: AppTheme.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                'حدث خطأ',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              _buildDialogButton(
                label: 'موافق',
                onTap: () => Navigator.of(context).pop(),
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CreateUnitBackgroundPainter extends CustomPainter {
  final double animationValue;

  _CreateUnitBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          AppTheme.primaryBlue.withOpacity(0.05),
          AppTheme.primaryPurple.withOpacity(0.03),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 50 * animationValue;
    
    path.moveTo(0, size.height * 0.5);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.5 +
          waveHeight *
              math.sin(x / size.width * 2 * 3.14159 + animationValue * 2 * 3.14159);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}