import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../bloc/unit_details/unit_details_bloc.dart';
import '../widgets/unit_stats_card.dart';
import '../widgets/assign_sections_modal.dart';

class UnitDetailsPage extends StatefulWidget {
  final String unitId;

  const UnitDetailsPage({
    super.key,
    required this.unitId,
  });

  @override
  State<UnitDetailsPage> createState() => _UnitDetailsPageState();
}

class _UnitDetailsPageState extends State<UnitDetailsPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  bool _showAssignSectionsModal = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUnitDetails();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _contentFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutQuart,
    ));

    _contentController.forward();
  }

  void _loadUnitDetails() {
    context.read<UnitDetailsBloc>().add(
          LoadUnitDetailsEvent(unitId: widget.unitId),
        );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
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
          if (_showAssignSectionsModal)
            AssignSectionsModal(
              unitId: widget.unitId,
              onClose: () => setState(() => _showAssignSectionsModal = false),
              onAssign: (sectionIds) {
                context.read<UnitDetailsBloc>().add(
                      AssignToSectionsEvent(
                        unitId: widget.unitId,
                        sectionIds: sectionIds,
                      ),
                    );
                setState(() => _showAssignSectionsModal = false);
              },
            ),
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
            painter: _DetailsBackgroundPainter(
              rotation: _backgroundAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: BlocConsumer<UnitDetailsBloc, UnitDetailsState>(
        listener: (context, state) {
          if (state is UnitDeleted) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is UnitDetailsLoading) {
            return _buildLoadingState();
          }

          if (state is UnitDetailsError) {
            return _buildErrorState(state.message);
          }

          if (state is UnitDetailsLoaded) {
            return FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Column(
                  children: [
                    _buildResponsiveHeader(state),
                    Expanded(
                      child: _buildContent(state),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // تحسين الـ Header ليكون responsive
  Widget _buildResponsiveHeader(UnitDetailsLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصف الأول: زر الرجوع والعنوان والإجراءات الأساسية
                Row(
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
                              state.unit.name,
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXSmall),
                          // استخدام Wrap بدلاً من Row للـ chips
                          Wrap(
                            spacing: AppDimensions.spaceSmall,
                            runSpacing: AppDimensions.spaceXSmall,
                            children: [
                              _buildInfoChip(
                                Icons.apartment,
                                state.unit.unitTypeName,
                              ),
                              _buildInfoChip(
                                Icons.location_city,
                                state.unit.propertyName,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    // استخدام PopupMenuButton للإجراءات على الشاشات الصغيرة
                    if (isSmallScreen)
                      _buildActionsMenu(state)
                    else
                      _buildActionButtonsRow(state),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // قائمة منسدلة للإجراءات على الشاشات الصغيرة
  Widget _buildActionsMenu(UnitDetailsLoaded state) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.2),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.more_vert,
          color: AppTheme.textWhite,
          size: 20,
        ),
      ),
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'edit':
            context.push('/admin/units/${widget.unitId}/edit');
            break;
          case 'gallery':
            context.push('/admin/units/${widget.unitId}/gallery');
            break;
          case 'sections':
            setState(() => _showAssignSectionsModal = true);
            break;
          case 'delete':
            _showDeleteConfirmation(state);
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem('edit', Icons.edit, 'تعديل', AppTheme.primaryBlue),
        _buildMenuItem('gallery', Icons.image, 'الصور', AppTheme.primaryPurple),
        _buildMenuItem('sections', Icons.category, 'الأقسام', AppTheme.success),
        _buildMenuItem('delete', Icons.delete, 'حذف', AppTheme.error),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppDimensions.spaceSmall),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  // أزرار الإجراءات للشاشات الكبيرة (أيقونات فقط)
  Widget _buildActionButtonsRow(UnitDetailsLoaded state) {
    return Row(
      children: [
        _buildIconActionButton(
          Icons.edit,
          'تعديل',
          AppTheme.primaryBlue,
          () => context.push('/admin/units/${widget.unitId}/edit'),
        ),
        const SizedBox(width: 8),
        _buildIconActionButton(
          Icons.image,
          'الصور',
          AppTheme.primaryPurple,
          () => context.push('/admin/units/${widget.unitId}/gallery'),
        ),
        const SizedBox(width: 8),
        _buildIconActionButton(
          Icons.category,
          'الأقسام',
          AppTheme.success,
          () => setState(() => _showAssignSectionsModal = true),
        ),
        const SizedBox(width: 8),
        _buildIconActionButton(
          Icons.delete,
          'حذف',
          AppTheme.error,
          () => _showDeleteConfirmation(state),
        ),
      ],
    );
  }

  // زر إجراء بأيقونة فقط مع Tooltip
  Widget _buildIconActionButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150), // تحديد عرض أقصى
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: AppDimensions.spaceXSmall),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UnitDetailsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          // Statistics Cards - جعلها responsive
          _buildResponsiveStatsSection(state),
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Basic Information
          _buildInfoSection(state),
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Pricing Information
          _buildPricingSection(state),
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Features
          if (state.unit.featuresList.isNotEmpty)
            _buildFeaturesSection(state),
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Dynamic Fields
          if (state.unit.dynamicFields.isNotEmpty)
            _buildDynamicFieldsSection(state),
          const SizedBox(height: AppDimensions.spaceLarge),
          
          // Images Preview
          if (state.unit.images?.isNotEmpty == true)
            _buildImagesSection(state),
        ],
      ),
    );
  }

  // تحسين قسم الإحصائيات ليكون responsive
  Widget _buildResponsiveStatsSection(UnitDetailsLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (isSmallScreen) {
      return Column(
        children: [
          UnitStatsCard(
            title: 'المشاهدات',
            value: '${state.unit.viewCount ?? 0}',
            icon: Icons.visibility,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          UnitStatsCard(
            title: 'الحجوزات',
            value: '${state.unit.bookingCount ?? 0}',
            icon: Icons.calendar_today,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          UnitStatsCard(
            title: 'الحالة',
            value: state.unit.isAvailable ? 'متاحة' : 'غير متاحة',
            icon: Icons.check_circle,
            color: state.unit.isAvailable ? AppTheme.success : AppTheme.error,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: UnitStatsCard(
            title: 'المشاهدات',
            value: '${state.unit.viewCount ?? 0}',
            icon: Icons.visibility,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: UnitStatsCard(
            title: 'الحجوزات',
            value: '${state.unit.bookingCount ?? 0}',
            icon: Icons.calendar_today,
            color: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMedium),
        Expanded(
          child: UnitStatsCard(
            title: 'الحالة',
            value: state.unit.isAvailable ? 'متاحة' : 'غير متاحة',
            icon: Icons.check_circle,
            color: state.unit.isAvailable ? AppTheme.success : AppTheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(UnitDetailsLoaded state) {
    return _buildSectionContainer(
      title: 'المعلومات الأساسية',
      icon: Icons.info,
      child: Column(
        children: [
          _buildInfoRow('الاسم', state.unit.name),
          _buildInfoRow('نوع الوحدة', state.unit.unitTypeName),
          _buildInfoRow('الكيان', state.unit.propertyName),
          if (state.unit.capacityDisplay.isNotEmpty)
            _buildInfoRow('السعة', state.unit.capacityDisplay),
        ],
      ),
    );
  }

  Widget _buildPricingSection(UnitDetailsLoaded state) {
    return _buildSectionContainer(
      title: 'التسعير',
      icon: Icons.attach_money,
      child: Column(
        children: [
          _buildInfoRow('السعر الأساسي', state.unit.basePrice.displayAmount),
          _buildInfoRow('طريقة التسعير', state.unit.pricingMethod.arabicLabel),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(UnitDetailsLoaded state) {
    return _buildSectionContainer(
      title: 'الميزات',
      icon: Icons.star,
      child: Wrap(
        spacing: AppDimensions.spaceSmall,
        runSpacing: AppDimensions.spaceSmall,
        children: state.unit.featuresList.map((feature) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              feature,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicFieldsSection(UnitDetailsLoaded state) {
    return _buildSectionContainer(
      title: 'معلومات إضافية',
      icon: Icons.dynamic_form,
      child: Column(
        children: state.unit.dynamicFields.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              ...group.fieldValues.map((field) {
                return _buildInfoRow(
                  field.displayName ?? field.fieldName ?? '',
                  field.fieldValue,
                );
              }).toList(),
              const SizedBox(height: AppDimensions.spaceMedium),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagesSection(UnitDetailsLoaded state) {
    return _buildSectionContainer(
      title: 'الصور',
      icon: Icons.image,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.unit.images!.length,
          itemBuilder: (context, index) {
            return Container(
              width: 120,
              margin: EdgeInsets.only(
                left: index == state.unit.images!.length - 1
                    ? 0
                    : AppDimensions.spaceSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                image: DecorationImage(
                  image: NetworkImage(state.unit.images![index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.glassLight.withOpacity(0.05),
            AppTheme.glassDark.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
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
            'جاري تحميل التفاصيل...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.1),
              AppTheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.error,
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
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _loadUnitDetails();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Text(
          'إعادة المحاولة',
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(UnitDetailsLoaded state) {
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
                Icons.warning_amber_rounded,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Text(
                'تأكيد الحذف',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                'هل أنت متأكد من حذف الوحدة "${state.unit.name}"؟',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogButton(
                      label: 'إلغاء',
                      onTap: () => Navigator.of(context).pop(),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMedium),
                  Expanded(
                    child: _buildDialogButton(
                      label: 'حذف',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.read<UnitDetailsBloc>().add(
                              DeleteUnitDetailsEvent(unitId: widget.unitId),
                            );
                      },
                      isPrimary: true,
                      isDanger: true,
                    ),
                  ),
                ],
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
    bool isPrimary = false,
    bool isDanger = false,
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
          gradient: isPrimary
              ? (isDanger
                  ? LinearGradient(
                      colors: [
                        AppTheme.error,
                        AppTheme.error.withOpacity(0.8),
                      ],
                    )
                  : AppTheme.primaryGradient)
              : null,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.textMuted.withOpacity(0.3),
                  width: 1,
                ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
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
}

class _DetailsBackgroundPainter extends CustomPainter {
  final double rotation;

  _DetailsBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.primaryBlue.withOpacity(0.05);

    // Draw animated circles
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);

    for (int i = 1; i <= 5; i++) {
      final radius = 100.0 * i;
      paint.color = AppTheme.primaryPurple.withOpacity(0.02);
      canvas.drawCircle(Offset.zero, radius, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}