// lib/features/admin_hub/presentation/pages/admin_hub_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class AdminHubPage extends StatefulWidget {
  const AdminHubPage({super.key});

  @override
  State<AdminHubPage> createState() => _AdminHubPageState();
}

class _AdminHubPageState extends State<AdminHubPage> 
    with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _glowController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  
  // Animations
  late final Animation<double> _glowAnim;
  late final Animation<double> _floatAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _entranceAnim;
  
  // UI State
  String? _hoveredCard;
  final ScrollController _scrollController = ScrollController();
  
  // Stats (في الواقع يجب جلبها من backend)
  final Map<String, dynamic> _stats = {
    'properties': 156,
    'users': 2341,
    'bookings': 89,
    'revenue': '45.2K',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Glow Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _glowAnim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Float Animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    
    _floatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _entranceAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    
    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width < 1024;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Premium Background
          _buildPremiumBackground(),
          
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildSliverAppBar(),
              
              // Content
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome Section
                    FadeTransition(
                      opacity: _entranceAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_entranceAnim),
                        child: _buildWelcomeSection(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Stats
                    FadeTransition(
                      opacity: _entranceAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _entranceAnim,
                          curve: const Interval(0.2, 1.0),
                        )),
                        child: _buildQuickStats(isSmallScreen),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Section Title
                    FadeTransition(
                      opacity: _entranceAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _entranceAnim,
                          curve: const Interval(0.3, 1.0),
                        )),
                        child: _buildSectionTitle(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Admin Cards Grid
                    FadeTransition(
                      opacity: _entranceAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _entranceAnim,
                          curve: const Interval(0.4, 1.0),
                        )),
                        child: _buildAdminGrid(
                          isSmallScreen: isSmallScreen,
                          isMediumScreen: isMediumScreen,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppTheme.darkBackground.withOpacity(0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.darkBackground.withOpacity(0.9),
                  AppTheme.darkBackground.withOpacity(0.7),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkBorder.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (rect) => AppTheme.primaryGradient.createShader(rect),
            child: Text(
              'لوحة التحكم',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Notifications
        _buildAppBarAction(
          icon: Icons.notifications_outlined,
          onTap: () => context.push('/notifications'),
          badge: '3',
        ),
        // Settings
        _buildAppBarAction(
          icon: Icons.settings_outlined,
          onTap: () => context.push('/settings'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: AppTheme.textLight,
              size: 22,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              onTap();
            },
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.error, AppTheme.primaryViolet],
                  ),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnim, _floatAnim]),
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
          child: Stack(
            children: [
              // Gradient Orbs
              Positioned(
                top: -100 + _floatAnim.value,
                right: -50,
                child: Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.08 * _glowAnim.value),
                          AppTheme.primaryBlue.withOpacity(0.02 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              Positioned(
                bottom: -150 + (_floatAnim.value * -1),
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryPurple.withOpacity(0.06 * _glowAnim.value),
                        AppTheme.primaryPurple.withOpacity(0.01 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Transform.scale(
                  scale: 1 / _pulseAnim.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.neonPurple.withOpacity(0.05 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Grid Pattern
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _GridPatternPainter(
                  color: AppTheme.darkBorder.withOpacity(0.03),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'صباح الخير';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'مساء الخير';
      greetingIcon = Icons.wb_twilight_outlined;
    } else {
      greeting = 'مساء الخير';
      greetingIcon = Icons.nights_stay_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.05),
            AppTheme.primaryPurple.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      greetingIcon,
                      color: AppTheme.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      greeting,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppTheme.textWhite,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في لوحة التحكم الخاصة بك',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'آخر تسجيل دخول: ${_formatLastLogin()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Decorative Element
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isSmallScreen) {
    final stats = [
      _StatItem(
        label: 'العقارات',
        value: _stats['properties'].toString(),
        icon: Icons.apartment_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
        ),
        trend: '+12%',
        isPositive: true,
      ),
      _StatItem(
        label: 'المستخدمون',
        value: _stats['users'].toString(),
        icon: Icons.people_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryViolet],
        ),
        trend: '+8%',
        isPositive: true,
      ),
      _StatItem(
        label: 'الحجوزات',
        value: _stats['bookings'].toString(),
        icon: Icons.calendar_month_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.neonGreen, AppTheme.primaryCyan],
        ),
        trend: '-3%',
        isPositive: false,
      ),
      _StatItem(
        label: 'الإيرادات',
        value: '\$${_stats['revenue']}',
        icon: Icons.attach_money_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.warning, AppTheme.neonPurple],
        ),
        trend: '+24%',
        isPositive: true,
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isSmallScreen ? 1.3 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic, // تغيير المنحنى لتجنب تجاوز القيمة 1.0
          builder: (context, value, child) {
            // التأكد من أن القيمة بين 0 و 1
            final clampedValue = value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: 0.8 + (0.2 * clampedValue), // تأثير scale أكثر نعومة
              child: Opacity(
                opacity: clampedValue,
                child: _buildStatCard(stats[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.5),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.gradient.colors.first.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: stat.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stat.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stat.isPositive
                      ? AppTheme.success.withOpacity(0.1)
                      : AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      stat.isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: stat.isPositive
                          ? AppTheme.success
                          : AppTheme.error,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      stat.trend,
                      style: AppTextStyles.caption.copyWith(
                        color: stat.isPositive
                            ? AppTheme.success
                            : AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'الوصول السريع',
              style: AppTextStyles.heading2.copyWith(
                color: AppTheme.textWhite,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            'اختر القسم الذي تريد إدارته',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminGrid({
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    final items = _adminItems(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic, // منحنى آمن
          builder: (context, value, child) {
            final clampedValue = value.clamp(0.0, 1.0);
            return Transform.translate(
              offset: Offset(0, 20 * (1 - clampedValue)),
              child: Opacity(
                opacity: clampedValue,
                child: _PremiumAdminCard(
                  item: item,
                  onHover: (isHovered) {
                    setState(() {
                      _hoveredCard = isHovered ? item.id : null;
                    });
                  },
                  isHovered: _hoveredCard == item.id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_AdminItem> _adminItems(BuildContext context) {
    return [
      _AdminItem(
        id: 'properties',
        label: 'العقارات',
        icon: Icons.apartment_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
        ),
        onTap: () => context.push('/admin/properties'),
        description: 'إدارة جميع العقارات',
      ),
      _AdminItem(
        id: 'property-types',
        label: 'أنواع العقارات',
        icon: Icons.category_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
        ),
        onTap: () => context.push('/admin/property-types'),
        description: 'تصنيفات العقارات',
      ),
      _AdminItem(
        id: 'units',
        label: 'الوحدات',
        icon: Icons.maps_home_work_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.neonPurple, AppTheme.neonBlue],
        ),
        onTap: () => context.push('/admin/units'),
        description: 'الوحدات السكنية',
      ),
      _AdminItem(
        id: 'services',
        label: 'الخدمات',
        icon: Icons.room_service_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
        ),
        onTap: () => context.push('/admin/services'),
        description: 'خدمات إضافية',
      ),
      _AdminItem(
        id: 'amenities',
        label: 'المرافق',
        icon: Icons.auto_awesome_mosaic_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
        ),
        onTap: () => context.push('/admin/amenities'),
        description: 'مرافق العقارات',
      ),
      _AdminItem(
        id: 'reviews',
        label: 'المراجعات',
        icon: Icons.reviews_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryViolet],
        ),
        onTap: () => context.push('/admin/reviews'),
        description: 'آراء العملاء',
      ),
      _AdminItem(
        id: 'cities',
        label: 'المدن',
        icon: Icons.location_city_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryViolet, AppTheme.neonGreen],
        ),
        onTap: () => context.push('/admin/cities'),
        description: 'المدن المتاحة',
      ),
      _AdminItem(
        id: 'users',
        label: 'المستخدمون',
        icon: Icons.people_alt_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.neonGreen, AppTheme.neonBlue],
        ),
        onTap: () => context.push('/admin/users'),
        description: 'إدارة المستخدمين',
      ),
      _AdminItem(
        id: 'audit-logs',
        label: 'سجلات التدقيق',
        icon: Icons.receipt_long_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.neonBlue, AppTheme.primaryBlue],
        ),
        onTap: () => context.push('/admin/audit-logs'),
        description: 'سجل النشاطات',
      ),
      _AdminItem(
        id: 'availability',
        label: 'التوفر والأسعار',
        icon: Icons.calendar_month_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.neonPurple],
        ),
        onTap: () => context.push('/admin/availability-pricing'),
        description: 'جدولة الأسعار',
      ),
      _AdminItem(
        id: 'currencies',
        label: 'العملات',
        icon: Icons.payments_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.warning, AppTheme.neonPurple],
        ),
        onTap: () => context.push('/admin/currencies'),
        description: 'إدارة العملات',
      ),
      _AdminItem(
        id: 'notifications',
        label: 'الإشعارات',
        icon: Icons.notifications_active_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryCyan],
        ),
        onTap: () => context.push('/notifications'),
        description: 'رسائل النظام',
      ),
    ];
  }

  String _formatLastLogin() {
    final now = DateTime.now();
    final lastLogin = now.subtract(const Duration(hours: 2));
    final difference = now.difference(lastLogin);
    
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

// Data Models
class _AdminItem {
  final String id;
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
  final String description;

  _AdminItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.description,
  });
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String trend;
  final bool isPositive;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.trend,
    required this.isPositive,
  });
}

// Premium Admin Card Widget
class _PremiumAdminCard extends StatefulWidget {
  final _AdminItem item;
  final Function(bool) onHover;
  final bool isHovered;

  const _PremiumAdminCard({
    required this.item,
    required this.onHover,
    required this.isHovered,
  });

  @override
  State<_PremiumAdminCard> createState() => _PremiumAdminCardState();
}

class _PremiumAdminCardState extends State<_PremiumAdminCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          HapticFeedback.lightImpact();
          widget.item.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: widget.isHovered ? _rotateAnimation.value : 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isHovered
                            ? widget.item.gradient.colors.first.withOpacity(0.3)
                            : AppTheme.shadowDark.withOpacity(0.2),
                        blurRadius: widget.isHovered ? 20 : 10,
                        offset: Offset(0, widget.isHovered ? 8 : 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: widget.isHovered ? 20 : 10,
                        sigmaY: widget.isHovered ? 20 : 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isHovered
                                ? [
                                    AppTheme.darkCard.withOpacity(0.9),
                                    AppTheme.darkCard.withOpacity(0.7),
                                  ]
                                : [
                                    AppTheme.darkCard.withOpacity(0.6),
                                    AppTheme.darkCard.withOpacity(0.4),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.isHovered
                                ? widget.item.gradient.colors.first.withOpacity(0.3)
                                : AppTheme.darkBorder.withOpacity(0.2),
                            width: widget.isHovered ? 1.5 : 0.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background Glow
                            if (widget.isHovered)
                              Positioned(
                                top: -30,
                                right: -30,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        widget.item.gradient.colors.first
                                            .withOpacity(0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Icon
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: widget.isHovered ? 48 : 44,
                                    height: widget.isHovered ? 48 : 44,
                                    decoration: BoxDecoration(
                                      gradient: widget.item.gradient,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: widget.isHovered
                                          ? [
                                              BoxShadow(
                                                color: widget.item.gradient.colors.first
                                                    .withOpacity(0.5),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Icon(
                                      widget.item.icon,
                                      color: Colors.white,
                                      size: widget.isHovered ? 24 : 22,
                                    ),
                                  ),
                                  
                                  // Text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.item.label,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppTheme.textWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        height: widget.isHovered ? 18 : 0,
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: widget.isHovered ? 1 : 0,
                                          child: Text(
                                            widget.item.description,
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppTheme.textMuted,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Arrow Indicator
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: widget.isHovered ? 1 : 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.glassLight,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppTheme.textWhite,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Grid Pattern Painter
class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}