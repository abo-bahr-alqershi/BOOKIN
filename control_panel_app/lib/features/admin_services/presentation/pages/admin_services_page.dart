// lib/features/admin_services/presentation/pages/admin_services_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/pricing_model.dart';
import '../bloc/services_bloc.dart';
import '../bloc/services_event.dart';
import '../bloc/services_state.dart';
import '../widgets/futuristic_service_card.dart';
import '../widgets/futuristic_services_table.dart';
import 'create_service_page.dart';
import '../widgets/service_icon_picker.dart';
import '../widgets/service_details_dialog.dart';
import '../widgets/service_stats_card.dart';
import '../widgets/service_filters_widget.dart';
import '../utils/service_icons.dart';

/// 🎯 Admin Services Page
class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _particlesAnimationController;
  late AnimationController _glowAnimationController;

  // Animations
  late Animation<double> _backgroundRotationAnimation;
  late Animation<double> _glowAnimation;

  // Particles
  final List<_Particle> _particles = [];

  // View Mode
  bool _isGridView = true;

  // Selected Property
  String? _selectedPropertyId;
  String? _selectedPropertyName;

  // Search
  String _searchQuery = '';

  // Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _particlesAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundRotationAnimation = Tween<double>(
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
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  void _loadInitialData() {
    // Load all services by default so the page is not empty on first open
    context.read<ServicesBloc>().add(const LoadServicesEvent(
        serviceType: 'all', pageNumber: 1, pageSize: 20));
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _particlesAnimationController.dispose();
    _glowAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      final current = context.read<ServicesBloc>().state;
      if (current is ServicesLoaded &&
          current.paginatedServices != null &&
          current.paginatedServices!.hasNextPage &&
          !current.isLoadingMore) {
        context.read<ServicesBloc>().add(const LoadMoreServicesEvent());
      }
    }
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
          _buildFloatingParticles(),

          // Main Content with CustomScrollView for better scrolling
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header as SliverToBoxAdapter
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Stats Cards as SliverToBoxAdapter
              SliverToBoxAdapter(
                child: _buildStatsCards(),
              ),

              // Filters as SliverToBoxAdapter
              SliverToBoxAdapter(
                child: _buildFilters(),
              ),

              // Content as SliverToBoxAdapter - تصحيح المشكلة
              SliverToBoxAdapter(
                child: _buildContent(),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundRotationAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _GridPatternPainter(
              rotation: _backgroundRotationAnimation.value * 0.1,
              opacity: 0.03,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particlesAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particlesAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Title Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(
                                      0.3 + 0.2 * _glowAnimation.value,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.room_service_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إدارة الخدمات',
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppTheme.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'إدارة خدمات العقارات والتحكم في الأسعار',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // View Toggle
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkBorder.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      icon: Icons.grid_view_rounded,
                      isSelected: _isGridView,
                      onTap: () => setState(() => _isGridView = true),
                    ),
                    _buildViewToggleButton(
                      icon: Icons.view_list_rounded,
                      isSelected: !_isGridView,
                      onTap: () => setState(() => _isGridView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        if (state is ServicesLoaded) {
          return Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: ServiceStatsCard(
                      title: 'إجمالي الخدمات',
                      value: state.totalServices.toString(),
                      icon: Icons.room_service_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: ServiceStatsCard(
                      title: 'خدمات مدفوعة',
                      value: state.paidServices.toString(),
                      icon: Icons.attach_money_rounded,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: ServiceStatsCard(
                      title: 'أيقونات متاحة',
                      value: ServiceIcons.icons.length.toString(),
                      icon: Icons.palette_rounded,
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ServiceFiltersWidget(
        selectedPropertyId: _selectedPropertyId,
        selectedPropertyName: _selectedPropertyName,
        onPropertyChanged: (propertyId) {
          setState(() => _selectedPropertyId = propertyId);
          context.read<ServicesBloc>().add(
                SelectPropertyEvent(propertyId),
              );
        },
        onPropertyFieldTap: _onPropertyFieldTap,
        onClearProperty: () {
          setState(() {
            _selectedPropertyId = null;
            _selectedPropertyName = null;
          });
          context.read<ServicesBloc>().add(const SelectPropertyEvent(null));
        },
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() => _searchQuery = query);
          context.read<ServicesBloc>().add(
                SearchServicesEvent(query),
              );
        },
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        if (state is ServicesLoading) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            child: const LoadingWidget(),
          );
        }

        if (state is ServicesError) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadInitialData,
            ),
          );
        }

        if (state is ServicesLoaded) {
          if (state.services.isEmpty) {
            return Container(
              height: 400,
              alignment: Alignment.center,
              child: const EmptyWidget(
                message: 'لا توجد خدمات حالياً',
              ),
            );
          }

          return _isGridView
              ? _buildGridView(state.services, state)
              : _buildListView(state.services, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGridView(List<Service> services, ServicesLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return FuturisticServiceCard(
                service: service,
                onTap: () => _showServiceDetails(service),
                onEdit: () => _showEditDialog(service),
                onDelete: () => _confirmDelete(service),
              );
            },
          ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Service> services, ServicesLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FuturisticServicesTable(
            services: services,
            onServiceTap: _showServiceDetails,
            onEdit: _showEditDialog,
            onDelete: _confirmDelete,
            controller: ScrollController(),
            onLoadMore: state.paginatedServices?.hasNextPage == true
                ? () => context
                    .read<ServicesBloc>()
                    .add(const LoadMoreServicesEvent())
                : null,
            hasReachedMax: !(state.paginatedServices?.hasNextPage == true),
            isLoadingMore: state.isLoadingMore,
          ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _navigateToCreatePage,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreatePage() async {
    HapticFeedback.mediumImpact();
    final result = await context.push('/admin/services/create',
        extra: {'propertyId': _selectedPropertyId});
    if (result is Map && result['refresh'] == true) {
      final pid = (result['propertyId'] as String?) ?? _selectedPropertyId;
      setState(() => _selectedPropertyId = pid);
      if (pid != null) {
        context.read<ServicesBloc>().add(LoadServicesEvent(propertyId: pid));
      } else {
        context.read<ServicesBloc>().add(const LoadServicesEvent(
            serviceType: 'all', pageNumber: 1, pageSize: 20));
      }
    }
  }

  void _onPropertyFieldTap() {
    HapticFeedback.lightImpact();
    context.push('/helpers/search/properties', extra: {
      'allowMultiSelect': false,
      'onPropertySelected': (dynamic property) {
        // property has id & name per PropertySearchPage model
        setState(() {
          _selectedPropertyId = property.id as String?;
          _selectedPropertyName = property.name as String?;
        });
        context
            .read<ServicesBloc>()
            .add(SelectPropertyEvent(_selectedPropertyId));
      },
    });
  }

  Future<void> _showEditDialog(Service service) async {
    HapticFeedback.lightImpact();
    final result = await context.push('/admin/services/${service.id}/edit',
        extra: service);
    if (result is Map && result['refresh'] == true) {
      if (_selectedPropertyId != null) {
        context
            .read<ServicesBloc>()
            .add(LoadServicesEvent(propertyId: _selectedPropertyId));
      } else {
        context.read<ServicesBloc>().add(const LoadServicesEvent(
            serviceType: 'all', pageNumber: 1, pageSize: 20));
      }
    }
  }

  void _showServiceDetails(Service service) {
    HapticFeedback.lightImpact();
    context.read<ServicesBloc>().add(LoadServiceDetailsEvent(service.id));
    showDialog(
      context: context,
      builder: (context) => ServiceDetailsDialog(service: service),
    );
  }

  void _confirmDelete(Service service) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد الحذف',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف خدمة "${service.name}"؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // استخدم سياق الصفحة الذي يحتوي على مزود البلوك، وليس سياق الديالوج
              context.read<ServicesBloc>().add(
                    DeleteServiceEvent(service.id),
                  );
              Navigator.of(dialogCtx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'حذف',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Model - كلاس مفقود
class _Particle {
  late double x, y, z;
  late double vx, vy;
  late double radius;
  late double opacity;
  late Color color;

  _Particle() {
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

// Particle Painter - كلاس مفقود
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
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
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        );

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

// Grid Pattern Painter - كلاس مفقود
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
