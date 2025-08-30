import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../bloc/users_list/users_list_bloc.dart';
import '../widgets/futuristic_user_card.dart';
import '../widgets/futuristic_users_table.dart';
import '../widgets/user_filters_widget.dart';
import '../widgets/user_stats_card.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _entranceController;
  
  // Animations
  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _entranceAnimation;
  
  // Layout
  bool _isGridView = false;
  
  // Search & Filters
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  
  // Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUsers();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
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
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutQuart,
    );
    
    _entranceController.forward();
  }

  void _loadUsers() {
    context.read<UsersListBloc>().add(LoadUsersEvent());
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        context.read<UsersListBloc>().add(LoadMoreUsersEvent());
      }
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _entranceController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Advanced animated background
          _buildAnimatedBackground(),
          
          // Floating particles
          _buildFloatingParticles(),
          
          // Main content
          _buildMainContent(isDesktop, isTablet),
          
          // Floating Action Button
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundRotation, _glowAnimation]),
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
              // Grid pattern
              CustomPaint(
                painter: _GridPatternPainter(
                  rotation: _backgroundRotation.value * 0.1,
                  opacity: 0.03,
                ),
                size: Size.infinite,
              ),
              
              // Wave overlay
              CustomPaint(
                painter: _WaveOverlayPainter(
                  animation: _glowAnimation.value,
                  color: AppTheme.primaryBlue.withOpacity(0.02),
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            animation: _particleController.value,
            particleCount: 30,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isTablet) {
    return SafeArea(
      child: Column(
        children: [
          // Futuristic App Bar
          _buildFuturisticAppBar(),
          
          // Stats Cards
          _buildStatsSection(),
          
          // Search and Filters
          _buildSearchAndFilters(),
          
          // Users List/Grid
          Expanded(
            child: AnimatedBuilder(
              animation: _entranceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _entranceAnimation.value)),
                  child: Opacity(
                    opacity: _entranceAnimation.value,
                    child: _buildUsersContent(isDesktop, isTablet),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticAppBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
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
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
            ),
            child: Row(
              children: [
                // Back button
                _buildGlowingIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                
                const SizedBox(width: AppDimensions.spaceMedium),
                
                // Title with gradient
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        AppTheme.primaryCyan,
                        AppTheme.primaryBlue,
                        AppTheme.primaryPurple,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'إدارة المستخدمين',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // View toggle
                _buildViewToggle(),
                
                const SizedBox(width: AppDimensions.spaceMedium),
                
                // Export button
                _buildGlowingIconButton(
                  icon: Icons.file_download_outlined,
                  onTap: _exportUsers,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
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
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(
                    0.3 * _glowAnimation.value,
                  ),
                  blurRadius: 10 * _glowAnimation.value,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
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
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _buildViewOption(
            icon: Icons.view_list_rounded,
            isSelected: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
          ),
          _buildViewOption(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.primaryGradient
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.white
              : AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      child: BlocBuilder<UsersListBloc, UsersListState>(
        builder: (context, state) {
          if (state is UsersListLoaded) {
            return ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                UserStatsCard(
                  title: 'إجمالي المستخدمين',
                  value: state.totalCount.toString(),
                  icon: Icons.people_rounded,
                  gradient: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                  animationDelay: const Duration(milliseconds: 100),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                UserStatsCard(
                  title: 'المستخدمين النشطين',
                  value: state.users.where((u) => u.isActive).length.toString(),
                  icon: Icons.verified_user_rounded,
                  gradient: [AppTheme.success, AppTheme.neonGreen],
                  animationDelay: const Duration(milliseconds: 200),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                UserStatsCard(
                  title: 'المستخدمين الجدد',
                  value: _getNewUsersCount(state.users).toString(),
                  icon: Icons.person_add_rounded,
                  gradient: [AppTheme.warning, AppTheme.neonBlue],
                  animationDelay: const Duration(milliseconds: 300),
                ),
                const SizedBox(width: AppDimensions.spaceMedium),
                UserStatsCard(
                  title: 'المستخدمين غير النشطين',
                  value: state.users.where((u) => !u.isActive).length.toString(),
                  icon: Icons.person_off_rounded,
                  gradient: [AppTheme.error, AppTheme.primaryViolet],
                  animationDelay: const Duration(milliseconds: 400),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          // Search bar
          _buildFuturisticSearchBar(),
          
          // Filters
          if (_showFilters) ...[
            const SizedBox(height: AppDimensions.spaceMedium),
            UserFiltersWidget(
              onApplyFilters: (filters) {
                context.read<UsersListBloc>().add(
                  FilterUsersEvent(
                    roleId: filters['roleId'],
                    isActive: filters['isActive'],
                    createdAfter: filters['createdAfter'],
                    createdBefore: filters['createdBefore'],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFuturisticSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              const SizedBox(width: AppDimensions.paddingMedium),
              
              // Search icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
              
              // Search field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: 'البحث عن مستخدم...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    context.read<UsersListBloc>().add(
                      SearchUsersEvent(searchTerm: value),
                    );
                  },
                ),
              ),
              
              // Filter button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showFilters = !_showFilters);
                },
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: _showFilters
                        ? AppTheme.primaryGradient
                        : null,
                    color: !_showFilters
                        ? AppTheme.darkSurface.withOpacity(0.5)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: _showFilters
                        ? Colors.white
                        : AppTheme.textMuted,
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersContent(bool isDesktop, bool isTablet) {
    return BlocBuilder<UsersListBloc, UsersListState>(
      builder: (context, state) {
        if (state is UsersListLoading) {
          return _buildLoadingState();
        }
        
        if (state is UsersListError) {
          return _buildErrorState(state.message);
        }
        
        if (state is UsersListLoaded) {
          if (state.users.isEmpty) {
            return _buildEmptyState();
          }
          
          if (_isGridView) {
            return _buildGridView(state, isDesktop, isTablet);
          }
          
          return _buildTableView(state);
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
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(_glowAnimation.value),
                      AppTheme.primaryPurple.withOpacity(_glowAnimation.value * 0.5),
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
          Text(
            'جاري تحميل المستخدمين...',
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
              onPressed: _loadUsers,
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.primaryPurple.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            Text(
              'لا يوجد مستخدمين',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              'لم يتم العثور على أي مستخدمين',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(UsersListLoaded state, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UsersListBloc>().add(RefreshUsersEvent());
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.spaceMedium,
          mainAxisSpacing: AppDimensions.spaceMedium,
          childAspectRatio: 0.85,
        ),
        itemCount: state.users.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return _buildLoadMoreIndicator();
          }
          
          final user = state.users[index];
          return FuturisticUserCard(
            user: user,
            animationDelay: Duration(milliseconds: index * 50),
            onTap: () => _navigateToUserDetails(user.id),
            onStatusToggle: (activate) {
              context.read<UsersListBloc>().add(
                ToggleUserStatusEvent(
                  userId: user.id,
                  activate: activate,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTableView(UsersListLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UsersListBloc>().add(RefreshUsersEvent());
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            FuturisticUsersTable(
              users: state.users,
              onUserTap: _navigateToUserDetails,
              onStatusToggle: (userId, activate) {
                context.read<UsersListBloc>().add(
                  ToggleUserStatusEvent(
                    userId: userId,
                    activate: activate,
                  ),
                );
              },
              onSort: (sortBy, isAscending) {
                context.read<UsersListBloc>().add(
                  SortUsersEvent(
                    sortBy: sortBy,
                    isAscending: isAscending,
                  ),
                );
              },
            ),
            if (state.isLoadingMore)
              _buildLoadMoreIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.primaryBlue,
          ),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: AppDimensions.paddingLarge,
      right: AppDimensions.paddingLarge,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(
                    0.4 + 0.2 * _glowAnimation.value,
                  ),
                  blurRadius: 20 + 10 * _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _navigateToCreateUser,
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('إضافة مستخدم'),
            ),
          );
        },
      ),
    );
  }

  // Helper methods
  int _getNewUsersCount(List<dynamic> users) {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return users.where((user) {
      return user.createdAt.isAfter(lastWeek);
    }).length;
  }

  void _navigateToUserDetails(String userId) {
    context.push('/admin/users/$userId');
  }

  void _navigateToCreateUser() {
    context.push('/admin/users/create');
  }

  void _exportUsers() {
    // Implement export functionality
  }
}

// Custom Painters
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
      ..strokeWidth = 0.5;

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

class _WaveOverlayPainter extends CustomPainter {
  final double animation;
  final Color color;

  _WaveOverlayPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.9 + 
                math.sin((x / size.width * 4 * math.pi) + 
                        (animation * 2 * math.pi)) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlesPainter extends CustomPainter {
  final double animation;
  final int particleCount;

  _ParticlesPainter({
    required this.animation,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (animation + i / particleCount) % 1.0;
      final y = size.height * progress;
      final x = size.width * 0.5 + 
                math.sin(progress * math.pi * 2 + i) * size.width * 0.4;
      
      final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0);
      final radius = 1 + math.sin(progress * math.pi) * 2;
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity * 0.3);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}