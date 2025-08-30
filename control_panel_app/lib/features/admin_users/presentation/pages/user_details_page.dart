import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/user_details/user_details_bloc.dart';
import '../widgets/user_form_dialog.dart';
import '../widgets/user_role_selector.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;

  const UserDetailsPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _entranceController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _entranceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  
  // Tab Controller
  late TabController _tabController;
  
  // Particles
  final List<_Particle> _particles = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadUserDetails();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuart,
    );
    
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    
    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );
    
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    
    _tabController = TabController(length: 4, vsync: this);
    
    _entranceController.forward();
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  void _loadUserDetails() {
    context.read<UserDetailsBloc>().add(
      LoadUserDetailsEvent(userId: widget.userId),
    );
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _entranceController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _tabController.dispose();
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
          _buildFloatingParticles(),
          
          // Main Content
          _buildMainContent(),
          
          // Floating Action Buttons
          _buildFloatingActions(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundRotation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.95),
                AppTheme.darkBackground3.withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Geometric pattern
              CustomPaint(
                painter: _GeometricPatternPainter(
                  rotation: _backgroundRotation.value,
                  color: AppTheme.primaryBlue.withOpacity(0.03),
                ),
                size: Size.infinite,
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      AppTheme.darkBackground.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            animation: _floatingAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<UserDetailsBloc, UserDetailsState>(
      builder: (context, state) {
        if (state is UserDetailsLoading) {
          return _buildLoadingState();
        }
        
        if (state is UserDetailsError) {
          return _buildErrorState(state.message);
        }
        
        if (state is UserDetailsLoaded) {
          return _buildLoadedContent(state);
        }
        
        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(_pulseAnimation.value),
                      AppTheme.primaryPurple.withOpacity(_pulseAnimation.value * 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spaceLarge),
          ShimmerText(
            text: 'جاري تحميل بيانات المستخدم...',
            style: AppTextStyles.bodyLarge.copyWith(
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
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.1),
              AppTheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppDimensions.spaceMedium),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading3.copyWith(
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
            ElevatedButton.icon(
              onPressed: _loadUserDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(UserDetailsLoaded state) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          _buildAppBar(state),
          
          // User Header
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _entranceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _entranceAnimation.value)),
                  child: Opacity(
                    opacity: _entranceAnimation.value,
                    child: _buildUserHeader(state),
                  ),
                );
              },
            ),
          ),
          
          // Stats Cards
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _entranceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _entranceAnimation.value)),
                  child: Opacity(
                    opacity: _entranceAnimation.value,
                    child: _buildStatsCards(state),
                  ),
                );
              },
            ),
          ),
          
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              glowAnimation: _glowAnimation,
            ),
          ),
          
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewTab(state),
                _buildBookingsTab(state),
                _buildReviewsTab(state),
                _buildActivityTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(UserDetailsLoaded state) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildBackButton(),
      actions: [
        _buildActionButton(
          icon: Icons.edit_rounded,
          onTap: () => _showEditDialog(state),
        ),
        _buildActionButton(
          icon: Icons.security_rounded,
          onTap: () => _showRoleSelector(state),
        ),
        _buildActionButton(
          icon: state.userDetails.isActive
              ? Icons.block_rounded
              : Icons.check_circle_rounded,
          onTap: () => _toggleUserStatus(state),
          color: state.userDetails.isActive
              ? AppTheme.error
              : AppTheme.success,
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.pop();
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
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
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(
                      0.2 * _glowAnimation.value,
                    ),
                    blurRadius: 10 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.7),
                AppTheme.darkCard.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (color ?? AppTheme.primaryBlue).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserDetailsLoaded state) {
    final user = state.userDetails;
    
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            children: [
              // Avatar
              _buildUserAvatar(user),
              
              const SizedBox(width: AppDimensions.spaceLarge),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status
                    Row(
                      children: [
                        Text(
                          user.userName,
                          style: AppTextStyles.heading2.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSmall),
                        _buildStatusBadge(user.isActive),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceSmall),
                    
                    // Email
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      text: user.email,
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    
                    // Phone
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      text: user.phoneNumber,
                    ),
                    
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    
                    // Join Date
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: 'انضم في ${_formatDate(user.createdAt)}',
                    ),
                    
                    // Role and Property (if exists)
                    if (user.role != null) ...[
                      const SizedBox(height: AppDimensions.spaceMedium),
                      _buildRoleBadge(user.role!),
                    ],
                    
                    if (user.propertyName != null) ...[
                      const SizedBox(height: AppDimensions.spaceSmall),
                      _buildPropertyInfo(user.propertyName!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(dynamic user) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatingAnimation.value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: user.avatarUrl != null
                  ? null
                  : AppTheme.primaryGradient,
              border: Border.all(
                color: user.isActive
                    ? AppTheme.success.withOpacity(0.5)
                    : AppTheme.darkBorder,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: user.isActive
                      ? AppTheme.success.withOpacity(0.3)
                      : AppTheme.darkBorder.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(user.userName);
                      },
                    ),
                  )
                : _buildDefaultAvatar(user.userName),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.heading1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [AppTheme.success, AppTheme.neonGreen]
                  : [AppTheme.textMuted, AppTheme.darkBorder],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(
                        0.3 + 0.2 * _pulseAnimation.value,
                      ),
                      blurRadius: 10 + 5 * _pulseAnimation.value,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? 'نشط' : 'غير نشط',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textMuted.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getRoleGradient(role),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRoleGradient(role)[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(role),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _getRoleText(role),
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo(String propertyName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.business_rounded,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            propertyName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserDetailsLoaded state) {
    final user = state.userDetails;
    final stats = state.lifetimeStats;
    
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            title: 'الحجوزات',
            value: user.bookingsCount.toString(),
            icon: Icons.book_online_rounded,
            gradient: [AppTheme.primaryBlue, AppTheme.primaryPurple],
            delay: 100,
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          _buildStatCard(
            title: 'المدفوعات',
            value: '﷼${user.totalPayments.toStringAsFixed(0)}',
            icon: Icons.payments_rounded,
            gradient: [AppTheme.success, AppTheme.neonGreen],
            delay: 200,
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          _buildStatCard(
            title: 'المراجعات',
            value: user.reviewsCount.toString(),
            icon: Icons.star_rounded,
            gradient: [AppTheme.warning, AppTheme.neonBlue],
            delay: 300,
          ),
          if (stats != null) ...[
            const SizedBox(width: AppDimensions.spaceMedium),
            _buildStatCard(
              title: 'الليالي',
              value: stats.totalNightsStayed.toString(),
              icon: Icons.nights_stay_rounded,
              gradient: [AppTheme.primaryCyan, AppTheme.primaryViolet],
              delay: 400,
            ),
          ],
          if (user.propertyId != null) ...[
            const SizedBox(width: AppDimensions.spaceMedium),
            _buildStatCard(
              title: 'الوحدات',
              value: user.unitsCount?.toString() ?? '0',
              icon: Icons.home_work_rounded,
              gradient: [AppTheme.error, AppTheme.primaryViolet],
              delay: 500,
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            _buildStatCard(
              title: 'صافي الإيراد',
              value: '﷼${user.netRevenue?.toStringAsFixed(0) ?? '0'}',
              icon: Icons.trending_up_rounded,
              gradient: [AppTheme.success, AppTheme.primaryBlue],
              delay: 600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.7),
                  AppTheme.darkCard.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: gradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    Text(
                      title,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(UserDetailsLoaded state) {
    final user = state.userDetails;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'معلومات الحساب',
            icon: Icons.account_circle_rounded,
            children: [
              _buildDetailRow('معرف المستخدم', user.id),
              _buildDetailRow('الاسم', user.userName),
              _buildDetailRow('البريد الإلكتروني', user.email),
              _buildDetailRow('الهاتف', user.phoneNumber),
              _buildDetailRow('تاريخ الإنشاء', _formatDate(user.createdAt)),
              if (user.role != null)
                _buildDetailRow('الدور', _getRoleText(user.role!)),
              if (user.propertyName != null)
                _buildDetailRow('الكيان', user.propertyName!),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spaceMedium),
          
          _buildSectionCard(
            title: 'إحصائيات الحجوزات',
            icon: Icons.analytics_rounded,
            children: [
              _buildDetailRow('إجمالي الحجوزات', user.bookingsCount.toString()),
              _buildDetailRow('الحجوزات الملغاة', user.canceledBookingsCount.toString()),
              _buildDetailRow('الحجوزات المعلقة', user.pendingBookingsCount.toString()),
              if (user.firstBookingDate != null)
                _buildDetailRow('أول حجز', _formatDate(user.firstBookingDate!)),
              if (user.lastBookingDate != null)
                _buildDetailRow('آخر حجز', _formatDate(user.lastBookingDate!)),
            ],
          ),
          
          const SizedBox(height: AppDimensions.spaceMedium),
          
          _buildSectionCard(
            title: 'المعاملات المالية',
            icon: Icons.account_balance_wallet_rounded,
            children: [
              _buildDetailRow('إجمالي المدفوعات', '﷼${user.totalPayments.toStringAsFixed(2)}'),
              _buildDetailRow('إجمالي المردودات', '﷼${user.totalRefunds.toStringAsFixed(2)}'),
              if (user.netRevenue != null)
                _buildDetailRow('صافي الإيراد', '﷼${user.netRevenue!.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab(UserDetailsLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_online_rounded,
            size: 64,
            color: AppTheme.primaryBlue.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'قائمة الحجوزات',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'سيتم عرض حجوزات المستخدم هنا',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(UserDetailsLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: 64,
            color: AppTheme.warning.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'المراجعات',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'سيتم عرض مراجعات المستخدم هنا',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(UserDetailsLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 64,
            color: AppTheme.primaryCyan.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            'سجل النشاط',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          Text(
            'سيتم عرض سجل نشاط المستخدم هنا',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSmall),
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: AppDimensions.paddingLarge,
      right: AppDimensions.paddingLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingActionButton(
            icon: Icons.message_rounded,
            color: AppTheme.primaryBlue,
            onTap: _sendMessage,
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          _buildFloatingActionButton(
            icon: Icons.email_rounded,
            color: AppTheme.primaryPurple,
            onTap: _sendEmail,
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          _buildFloatingActionButton(
            icon: Icons.call_rounded,
            color: AppTheme.success,
            onTap: _makeCall,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 + 0.2 * _glowAnimation.value),
                  blurRadius: 15 + 10 * _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  // Helper Methods
  void _showEditDialog(UserDetailsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: state.userDetails,
        onSave: (updatedUser) {
          context.read<UserDetailsBloc>().add(
            UpdateUserDetailsEvent(
              userId: widget.userId,
              name: updatedUser['name'],
              email: updatedUser['email'],
              phone: updatedUser['phone'],
              profileImage: updatedUser['profileImage'],
            ),
          );
        },
      ),
    );
  }

  void _showRoleSelector(UserDetailsLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UserRoleSelector(
        currentRole: state.userDetails.role,
        onRoleSelected: (roleId) {
          context.read<UserDetailsBloc>().add(
            AssignUserRoleEvent(
              userId: widget.userId,
              roleId: roleId,
            ),
          );
        },
      ),
    );
  }

  void _toggleUserStatus(UserDetailsLoaded state) {
    context.read<UserDetailsBloc>().add(
      ToggleUserStatusEvent(
        userId: widget.userId,
        activate: !state.userDetails.isActive,
      ),
    );
  }

  void _sendMessage() {
    // Implement send message
  }

  void _sendEmail() {
    // Implement send email
  }

  void _makeCall() {
    // Implement make call
  }

  List<Color> _getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return [AppTheme.error, AppTheme.primaryViolet];
      case 'owner':
        return [AppTheme.primaryBlue, AppTheme.primaryPurple];
      case 'staff':
        return [AppTheme.warning, AppTheme.neonBlue];
      default:
        return [AppTheme.primaryCyan, AppTheme.neonGreen];
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'owner':
        return Icons.business_rounded;
      case 'staff':
        return Icons.badge_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير';
      case 'owner':
        return 'مالك';
      case 'staff':
        return 'موظف';
      case 'customer':
        return 'عميل';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Custom Painters
class _GeometricPatternPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _GeometricPatternPainter({
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);

    // Draw hexagonal pattern
    const radius = 50.0;
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 6; j++) {
        final x = i * radius * 3;
        final y = j * radius * math.sqrt(3);
        _drawHexagon(canvas, Offset(x, y), radius, paint);
      }
    }

    canvas.restore();
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  late double x, y, size, speed;
  late Color color;

  _Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 3 + 1;
    speed = math.Random().nextDouble() * 0.002 + 0.001;
    
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double animation;

  _ParticlesPainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y -= particle.speed;
      if (particle.y < 0) {
        particle.y = 1;
        particle.x = math.Random().nextDouble();
      }

      final paint = Paint()
        ..color = particle.color.withOpacity(0.3 * (1 - particle.y))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Animation<double> glowAnimation;

  _TabBarDelegate({
    required this.tabController,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.darkBackground,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.7),
              AppTheme.darkCard.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'نظرة عامة'),
                Tab(text: 'الحجوزات'),
                Tab(text: 'المراجعات'),
                Tab(text: 'النشاط'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// Shimmer Text Widget
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1,
      end: 2,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppTheme.textMuted,
                AppTheme.primaryBlue,
                AppTheme.textMuted,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}