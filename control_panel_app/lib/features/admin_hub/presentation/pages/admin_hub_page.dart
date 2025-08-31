import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminHubPage extends StatefulWidget {
  const AdminHubPage({super.key});

  @override
  State<AdminHubPage> createState() => _AdminHubPageState();
}

class _AdminHubPageState extends State<AdminHubPage> with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _adminItems(context);
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('لوحة التحكم'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _AdminNavCard(item: items[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (rect) => AppTheme.primaryGradient.createShader(rect),
          child: Text(
            'الانتقال السريع للإدارات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اختر القسم الذي تريد إدارته',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.12 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -20,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.neonPurple.withValues(alpha: 0.10 * _glowAnim.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_AdminItem> _adminItems(BuildContext context) {
    return [
      _AdminItem(
        label: 'العقارات',
        icon: Icons.apartment_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryViolet]),
        onTap: () => context.push('/admin/properties'),
      ),
      _AdminItem(
        label: 'أنواع العقارات',
        icon: Icons.category_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryViolet, AppTheme.neonPurple]),
        onTap: () => context.push('/admin/property-types'),
      ),
      _AdminItem(
        label: 'الوحدات',
        icon: Icons.maps_home_work_rounded,
        gradient: LinearGradient(colors: [AppTheme.neonPurple, AppTheme.neonBlue]),
        onTap: () => context.push('/admin/units'),
      ),
      _AdminItem(
        label: 'الخدمات',
        icon: Icons.room_service_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryCyan, AppTheme.primaryBlue]),
        onTap: () => context.push('/admin/services'),
      ),
      _AdminItem(
        label: 'المرافق',
        icon: Icons.auto_awesome_mosaic_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryPurple]),
        onTap: () => context.push('/admin/amenities'),
      ),
      _AdminItem(
        label: 'المراجعات',
        icon: Icons.reviews_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryPurple, AppTheme.primaryViolet]),
        onTap: () => context.push('/admin/reviews'),
      ),
      _AdminItem(
        label: 'المدن',
        icon: Icons.location_city_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryViolet, AppTheme.neonGreen]),
        onTap: () => context.push('/admin/cities'),
      ),
      _AdminItem(
        label: 'المستخدمون',
        icon: Icons.people_alt_rounded,
        gradient: LinearGradient(colors: [AppTheme.neonGreen, AppTheme.neonBlue]),
        onTap: () => context.push('/admin/users'),
      ),
      _AdminItem(
        label: 'سجلات التدقيق',
        icon: Icons.receipt_long_rounded,
        gradient: LinearGradient(colors: [AppTheme.neonBlue, AppTheme.primaryBlue]),
        onTap: () => context.push('/admin/audit-logs'),
      ),
      _AdminItem(
        label: 'التوفر والأسعار',
        icon: Icons.calendar_month_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.neonPurple]),
        onTap: () => context.push('/admin/availability-pricing'),
      ),
      _AdminItem(
        label: 'العملات',
        icon: Icons.payments_rounded,
        gradient: LinearGradient(colors: [AppTheme.neonPurple, AppTheme.neonGreen]),
        onTap: () => context.push('/admin/currencies'),
      ),
      _AdminItem(
        label: 'الإشعارات',
        icon: Icons.notifications_active_rounded,
        gradient: LinearGradient(colors: [AppTheme.primaryPurple, AppTheme.primaryCyan]),
        onTap: () => context.push('/notifications'),
      ),
    ];
  }
}

class _AdminItem {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  _AdminItem({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

class _AdminNavCard extends StatefulWidget {
  final _AdminItem item;
  const _AdminNavCard({required this.item});

  @override
  State<_AdminNavCard> createState() => _AdminNavCardState();
}

class _AdminNavCardState extends State<_AdminNavCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: InkWell(
        onTapDown: (_) => _controller.forward(),
        onTapCancel: () => _controller.reverse(),
        onTapUp: (_) => _controller.reverse(),
        onTap: widget.item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppTheme.cardGradient,
            border: Border.all(color: AppTheme.darkBorder.withValues(alpha: 0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (widget.item.gradient.colors.first).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: widget.item.gradient,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.item.gradient.colors.first).withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(widget.item.icon, color: Colors.white),
                    ),
                    Text(
                      widget.item.label,
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

