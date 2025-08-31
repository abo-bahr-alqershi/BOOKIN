import 'package:bookn_cp_app/features/property_types/domain/entities/property_type.dart';
import 'package:bookn_cp_app/features/property_types/domain/entities/unit_type.dart';
import 'package:bookn_cp_app/features/property_types/domain/entities/unit_type_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/property_types/property_types_bloc.dart';
import '../bloc/property_types/property_types_event.dart';
import '../bloc/property_types/property_types_state.dart';
import '../bloc/unit_types/unit_types_bloc.dart';
import '../bloc/unit_types/unit_types_event.dart';
import '../bloc/unit_types/unit_types_state.dart';
import '../bloc/unit_type_fields/unit_type_fields_bloc.dart';
import '../bloc/unit_type_fields/unit_type_fields_event.dart';
import '../bloc/unit_type_fields/unit_type_fields_state.dart';
import '../widgets/property_type_card.dart';
import '../widgets/unit_type_card.dart';
import '../widgets/unit_type_field_card.dart';
import '../widgets/property_type_modal.dart';
import '../widgets/unit_type_modal.dart';
import '../widgets/unit_type_field_modal.dart';
import '../widgets/icon_picker_modal.dart';
import '../widgets/futuristic_stats_card.dart';

/// 🎨 صفحة إدارة أنواع الكيانات والوحدات بتصميم Futuristic
class PropertyTypesPage extends StatefulWidget {
  const PropertyTypesPage({super.key});

  @override
  State<PropertyTypesPage> createState() => _PropertyTypesPageState();
}

class _PropertyTypesPageState extends State<PropertyTypesPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _waveAnimationController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _waveAnimation;
  
  // Particles
  final List<_FuturisticParticle> _particles = [];
  
  // Search & Filter Controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_FuturisticParticle());
    }
  }

  void _loadInitialData() {
    context.read<PropertyTypesBloc>().add(const LoadPropertyTypesEvent());
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowAnimationController.dispose();
    _particleAnimationController.dispose();
    _waveAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Floating Particles
          _buildParticlesLayer(),
          
          // Main Content
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundRotation,
        _waveAnimation,
        _glowAnimationController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.8),
                AppTheme.darkBackground3.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Wave Overlay
              CustomPaint(
                painter: _WaveBackgroundPainter(
                  waveAnimation: _waveAnimation.value,
                  glowIntensity: _glowAnimation.value,
                ),
                size: Size.infinite,
              ),
              
              // Grid Pattern
              CustomPaint(
                painter: _GridPatternPainter(
                  rotation: _backgroundRotation.value * 0.1,
                  opacity: 0.03,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticlesLayer() {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particleAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          // Futuristic Header
          _buildFuturisticHeader(),
          
          // Stats Cards
          _buildStatsSection(),
          
          // Main Content Area
          Expanded(
            child: _buildHierarchicalLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassLight.withOpacity(0.1),
                  AppTheme.glassLight.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated Logo
                _buildAnimatedLogo(),
                
                const SizedBox(width: AppDimensions.spaceMedium),
                
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'إدارة أنواع الكيانات',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'إدارة شاملة لأنواع الكيانات والوحدات والحقول الديناميكية',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                _buildHeaderActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildGlowingIconButton(
          icon: Icons.refresh_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            _loadInitialData();
          },
        ),
        const SizedBox(width: AppDimensions.spaceSmall),
        _buildGlowingIconButton(
          icon: Icons.filter_list_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            _showFilterOptions();
          },
        ),
      ],
    );
  }

  Widget _buildGlowingIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.2),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: BlocBuilder<PropertyTypesBloc, PropertyTypesState>(
        builder: (context, propertyState) {
          return BlocBuilder<UnitTypesBloc, UnitTypesState>(
            builder: (context, unitState) {
              return BlocBuilder<UnitTypeFieldsBloc, UnitTypeFieldsState>(
                builder: (context, fieldState) {
                  final propertyCount = propertyState is PropertyTypesLoaded 
                      ? propertyState.propertyTypes.length : 0;
                  final unitCount = unitState is UnitTypesLoaded 
                      ? unitState.unitTypes.length : 0;
                  final fieldCount = fieldState is UnitTypeFieldsLoaded 
                      ? fieldState.fields.length : 0;
                  
                  return Row(
                    children: [
                      Expanded(
                        child: FuturisticStatsCard(
                          title: 'أنواع الكيانات',
                          value: propertyCount.toString(),
                          icon: Icons.business_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                          ),
                          animationDelay: const Duration(milliseconds: 0),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: FuturisticStatsCard(
                          title: 'أنواع الوحدات',
                          value: unitCount.toString(),
                          icon: Icons.home_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          animationDelay: const Duration(milliseconds: 100),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: FuturisticStatsCard(
                          title: 'الحقول الديناميكية',
                          value: fieldCount.toString(),
                          icon: Icons.dynamic_form_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                          ),
                          animationDelay: const Duration(milliseconds: 200),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHierarchicalLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: Property Types
          Expanded(
            flex: 3,
            child: _buildPropertyTypesColumn(),
          ),
          
          const SizedBox(width: AppDimensions.spaceMedium),
          
          // Column 2: Unit Types
          Expanded(
            flex: 3,
            child: _buildUnitTypesColumn(),
          ),
          
          const SizedBox(width: AppDimensions.spaceMedium),
          
          // Column 3: Dynamic Fields
          Expanded(
            flex: 4,
            child: _buildFieldsColumn(),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypesColumn() {
    return _buildFuturisticColumn(
      title: 'أنواع الكيانات',
      icon: Icons.business_rounded,
      gradientColors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
      onAdd: () => _showPropertyTypeModal(),
      child: BlocBuilder<PropertyTypesBloc, PropertyTypesState>(
        builder: (context, state) {
          if (state is PropertyTypesLoading) {
            return _buildLoadingWidget();
          }
          
          if (state is PropertyTypesError) {
            return _buildErrorWidget(state.message);
          }
          
          if (state is PropertyTypesLoaded) {
            if (state.propertyTypes.isEmpty) {
              return _buildEmptyWidget('لا توجد أنواع كيانات');
            }
            
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.propertyTypes.length,
              itemBuilder: (context, index) {
                final propertyType = state.propertyTypes[index];
                final isSelected = state.selectedPropertyType?.id == propertyType.id;
                
                return PropertyTypeCard(
                  propertyType: propertyType,
                  isSelected: isSelected,
                  animationDelay: Duration(milliseconds: index * 50),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<PropertyTypesBloc>().add(
                      SelectPropertyTypeEvent(propertyTypeId: propertyType.id),
                    );
                    context.read<UnitTypesBloc>().add(
                      LoadUnitTypesEvent(propertyTypeId: propertyType.id),
                    );
                  },
                  onEdit: () => _showPropertyTypeModal(propertyType: propertyType),
                  onDelete: () => _confirmDelete(
                    title: 'حذف نوع الكيان',
                    message: 'هل أنت متأكد من حذف ${propertyType.name}؟',
                    onConfirm: () {
                      context.read<PropertyTypesBloc>().add(
                        DeletePropertyTypeEvent(propertyTypeId: propertyType.id),
                      );
                    },
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUnitTypesColumn() {
    return _buildFuturisticColumn(
      title: 'أنواع الوحدات',
      icon: Icons.home_rounded,
      gradientColors: [AppTheme.primaryPurple, AppTheme.primaryViolet],
      onAdd: () {
        final propertyState = context.read<PropertyTypesBloc>().state;
        if (propertyState is PropertyTypesLoaded && 
            propertyState.selectedPropertyType != null) {
          _showUnitTypeModal();
        } else {
          _showSnackBar('يرجى اختيار نوع كيان أولاً', isError: true);
        }
      },
      child: BlocBuilder<UnitTypesBloc, UnitTypesState>(
        builder: (context, state) {
          final propertyState = context.read<PropertyTypesBloc>().state;
          
          if (propertyState is! PropertyTypesLoaded || 
              propertyState.selectedPropertyType == null) {
            return _buildEmptyWidget('اختر نوع كيان لعرض الوحدات');
          }
          
          if (state is UnitTypesLoading) {
            return _buildLoadingWidget();
          }
          
          if (state is UnitTypesError) {
            return _buildErrorWidget(state.message);
          }
          
          if (state is UnitTypesLoaded) {
            if (state.unitTypes.isEmpty) {
              return _buildEmptyWidget('لا توجد أنواع وحدات');
            }
            
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.unitTypes.length,
              itemBuilder: (context, index) {
                final unitType = state.unitTypes[index];
                final isSelected = state.selectedUnitType?.id == unitType.id;
                
                return UnitTypeCard(
                  unitType: unitType,
                  isSelected: isSelected,
                  animationDelay: Duration(milliseconds: index * 50),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<UnitTypesBloc>().add(
                      SelectUnitTypeEvent(unitTypeId: unitType.id),
                    );
                    context.read<UnitTypeFieldsBloc>().add(
                      LoadUnitTypeFieldsEvent(unitTypeId: unitType.id),
                    );
                  },
                  onEdit: () => _showUnitTypeModal(unitType: unitType),
                  onDelete: () => _confirmDelete(
                    title: 'حذف نوع الوحدة',
                    message: 'هل أنت متأكد من حذف ${unitType.name}؟',
                    onConfirm: () {
                      context.read<UnitTypesBloc>().add(
                        DeleteUnitTypeEvent(unitTypeId: unitType.id),
                      );
                    },
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFieldsColumn() {
    return _buildFuturisticColumn(
      title: 'الحقول الديناميكية',
      icon: Icons.dynamic_form_rounded,
      gradientColors: [AppTheme.neonPurple, AppTheme.neonGreen],
      onAdd: () {
        final unitState = context.read<UnitTypesBloc>().state;
        if (unitState is UnitTypesLoaded && 
            unitState.selectedUnitType != null) {
          _showFieldModal();
        } else {
          _showSnackBar('يرجى اختيار نوع وحدة أولاً', isError: true);
        }
      },
      child: BlocBuilder<UnitTypeFieldsBloc, UnitTypeFieldsState>(
        builder: (context, state) {
          final unitState = context.read<UnitTypesBloc>().state;
          
          if (unitState is! UnitTypesLoaded || 
              unitState.selectedUnitType == null) {
            return _buildEmptyWidget('اختر نوع وحدة لعرض الحقول');
          }
          
          if (state is UnitTypeFieldsLoading) {
            return _buildLoadingWidget();
          }
          
          if (state is UnitTypeFieldsError) {
            return _buildErrorWidget(state.message);
          }
          
          if (state is UnitTypeFieldsLoaded) {
            if (state.fields.isEmpty) {
              return _buildEmptyWidget('لا توجد حقول ديناميكية');
            }
            
            return Column(
              children: [
                // Search Bar
                _buildFieldSearchBar(),
                
                const SizedBox(height: AppDimensions.spaceMedium),
                
                // Fields List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.filteredFields.length,
                    itemBuilder: (context, index) {
                      final field = state.filteredFields[index];
                      
                      return UnitTypeFieldCard(
                        field: field,
                        animationDelay: Duration(milliseconds: index * 50),
                        onEdit: () => _showFieldModal(field: field),
                        onDelete: () => _confirmDelete(
                          title: 'حذف الحقل',
                          message: 'هل أنت متأكد من حذف ${field.displayName}؟',
                          onConfirm: () {
                            context.read<UnitTypeFieldsBloc>().add(
                              DeleteFieldEvent(fieldId: field.fieldId),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFuturisticColumn({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onAdd,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.3),
            AppTheme.darkCard.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: gradientColors.first.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 220;
                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: gradientColors),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceSmall),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading3.copyWith(
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: _buildAddButton(onAdd, gradientColors),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSmall),
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ),
                        _buildAddButton(onAdd, gradientColors),
                      ],
                    );
                  },
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onTap, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'إضافة',
              style: AppTextStyles.buttonSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'البحث في الحقول...',
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
        ),
        onChanged: (value) {
          context.read<UnitTypeFieldsBloc>().add(
            SearchFieldsEvent(searchTerm: value),
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
        ),
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertyTypeModal({PropertyType? propertyType}) {
    showDialog(
      context: context,
      builder: (context) => PropertyTypeModal(
        propertyType: propertyType,
        onSave: (name, description, defaultAmenities, icon) {
          if (propertyType != null) {
            context.read<PropertyTypesBloc>().add(
              UpdatePropertyTypeEvent(
                propertyTypeId: propertyType.id,
                name: name,
                description: description,
                defaultAmenities: defaultAmenities,
                icon: icon,
              ),
            );
          } else {
            context.read<PropertyTypesBloc>().add(
              CreatePropertyTypeEvent(
                name: name,
                description: description,
                defaultAmenities: defaultAmenities,
                icon: icon,
              ),
            );
          }
        },
      ),
    );
  }

  void _showUnitTypeModal({UnitType? unitType}) {
    final propertyState = context.read<PropertyTypesBloc>().state;
    if (propertyState is! PropertyTypesLoaded || 
        propertyState.selectedPropertyType == null) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => UnitTypeModal(
        unitType: unitType,
        propertyTypeId: propertyState.selectedPropertyType!.id,
        onSave: (name, maxCapacity, icon, isHasAdults, isHasChildren, 
                 isMultiDays, isRequiredToDetermineTheHour) {
          if (unitType != null) {
            context.read<UnitTypesBloc>().add(
              UpdateUnitTypeEvent(
                unitTypeId: unitType.id,
                name: name,
                maxCapacity: maxCapacity,
                icon: icon,
                isHasAdults: isHasAdults,
                isHasChildren: isHasChildren,
                isMultiDays: isMultiDays,
                isRequiredToDetermineTheHour: isRequiredToDetermineTheHour,
              ),
            );
          } else {
            context.read<UnitTypesBloc>().add(
              CreateUnitTypeEvent(
                propertyTypeId: propertyState.selectedPropertyType!.id,
                name: name,
                maxCapacity: maxCapacity,
                icon: icon,
                isHasAdults: isHasAdults,
                isHasChildren: isHasChildren,
                isMultiDays: isMultiDays,
                isRequiredToDetermineTheHour: isRequiredToDetermineTheHour,
              ),
            );
          }
        },
      ),
    );
  }

  void _showFieldModal({UnitTypeField? field}) {
    final unitState = context.read<UnitTypesBloc>().state;
    if (unitState is! UnitTypesLoaded || 
        unitState.selectedUnitType == null) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => UnitTypeFieldModal(
        field: field,
        unitTypeId: unitState.selectedUnitType!.id,
        onSave: (fieldData) {
          if (field != null) {
            context.read<UnitTypeFieldsBloc>().add(
              UpdateFieldEvent(
                fieldId: field.fieldId,
                fieldData: fieldData,
              ),
            );
          } else {
            context.read<UnitTypeFieldsBloc>().add(
              CreateFieldEvent(
                unitTypeId: unitState.selectedUnitType!.id,
                fieldData: fieldData,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              'حذف',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    // TODO: Implement filter modal
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
      ),
    );
  }
}

// Particle Model
class _FuturisticParticle {
  late double x, y, z;
  late double vx, vy;
  late double radius;
  late double opacity;
  late Color color;
  
  _FuturisticParticle() {
    reset();
  }
  
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    radius = math.Random().nextDouble() * 2 + 0.5;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
  
  void update() {
    x += vx;
    y += vy;
    
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Custom Painters
class _ParticlePainter extends CustomPainter {
  final List<_FuturisticParticle> particles;
  final double animationValue;
  
  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WaveBackgroundPainter extends CustomPainter {
  final double waveAnimation;
  final double glowIntensity;
  
  _WaveBackgroundPainter({
    required this.waveAnimation,
    required this.glowIntensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withOpacity(0.03 * glowIntensity),
          AppTheme.primaryPurple.withOpacity(0.02 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final path = Path();
    path.moveTo(0, 0);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = 50 + 
                math.sin((x / size.width * 4 * math.pi) + 
                        (waveAnimation * 2 * math.pi)) * 30;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPatternPainter extends CustomPainter {
  final double rotation;
  final double opacity;
  
  _GridPatternPainter({
    required this.rotation,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    
    const spacing = 30.0;
    
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
    }
    
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y),
        paint,
      );
    }
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}