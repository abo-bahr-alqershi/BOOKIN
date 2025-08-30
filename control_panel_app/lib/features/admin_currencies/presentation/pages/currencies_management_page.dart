import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../domain/entities/currency.dart';
import '../bloc/currencies_bloc.dart';
import '../bloc/currencies_event.dart';
import '../bloc/currencies_state.dart';
import '../widgets/futuristic_currency_card.dart';
import '../widgets/futuristic_currency_form_modal.dart';
import '../widgets/currency_stats_card.dart';

class CurrenciesManagementPage extends StatefulWidget {
  const CurrenciesManagementPage({super.key});

  @override
  State<CurrenciesManagementPage> createState() => 
      _CurrenciesManagementPageState();
}

class _CurrenciesManagementPageState extends State<CurrenciesManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  final List<_Particle> _particles = [];
  Currency? _editingCurrency;
  bool _showFormModal = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle());
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Floating particles
          _buildParticles(),
          
          // Main content
          _buildMainContent(),
          
          // Floating action button
          _buildFloatingActionButton(),
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
            painter: _GridPainter(
              rotation: _backgroundAnimation.value * 0.1,
              opacity: 0.03,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
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
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 20),
          _buildStatsSection(),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _buildBackButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient
                    .createShader(bounds),
                child: Text(
                  'إدارة العملات',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'إدارة العملات وأسعار الصرف',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.5),
              AppTheme.darkCard.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.textWhite,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<CurrenciesBloc>().add(RefreshCurrenciesEvent());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
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
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.refresh_rounded,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<CurrenciesBloc, CurrenciesState>(
      builder: (context, state) {
        if (state is CurrenciesLoaded) {
          final defaultCurrency = state.currencies
              .firstWhere(
                (c) => c.isDefault,
                orElse: () => const Currency(
                  code: 'N/A',
                  arabicCode: 'غ/م',
                  name: 'Not Set',
                  arabicName: 'غير محدد',
                  isDefault: false,
                ),
              );

          return CurrencyStatsCard(
            totalCurrencies: state.currencies.length,
            activeCurrencies: state.currencies
                .where((c) => c.exchangeRate != null || c.isDefault)
                .length,
            defaultCurrency: defaultCurrency.code,
            lastUpdate: defaultCurrency.lastUpdated,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchBar() {
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
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              context.read<CurrenciesBloc>().add(
                SearchCurrenciesEvent(query: query),
              );
            },
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن عملة...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppTheme.primaryBlue,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CurrenciesBloc>().add(
                          const SearchCurrenciesEvent(query: ''),
                        );
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<CurrenciesBloc, CurrenciesState>(
      listener: (context, state) {
        if (state is CurrencyOperationSuccess) {
          _showSuccessSnackBar(state.message);
          if (_showFormModal) {
            Navigator.of(context).pop();
            setState(() {
              _showFormModal = false;
              _editingCurrency = null;
            });
          }
        } else if (state is CurrenciesError) {
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is CurrenciesLoading) {
          return const Center(child: FuturisticLoadingWidget());
        }

        if (state is CurrenciesError) {
          return Center(
            child: FuturisticErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<CurrenciesBloc>().add(LoadCurrenciesEvent());
              },
            ),
          );
        }

        if (state is CurrenciesLoaded) {
          if (state.filteredCurrencies.isEmpty) {
            return Center(
              child: FuturisticEmptyWidget(
                icon: Icons.currency_exchange_rounded,
                title: state.searchQuery.isNotEmpty
                    ? 'لا توجد نتائج'
                    : 'لا توجد عملات',
                subtitle: state.searchQuery.isNotEmpty
                    ? 'جرب البحث بكلمات أخرى'
                    : 'ابدأ بإضافة عملة جديدة',
                actionLabel: state.searchQuery.isEmpty ? 'إضافة عملة' : null,
                onAction: state.searchQuery.isEmpty
                    ? () => _openFormModal()
                    : null,
              ),
            );
          }

          return _buildCurrenciesList(state.filteredCurrencies);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrenciesList(List<Currency> currencies) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        final currency = currencies[index];
        return FuturisticCurrencyCard(
          currency: currency,
          onEdit: () => _openFormModal(currency: currency),
          onDelete: () => _confirmDelete(currency),
          onSetDefault: () => _setDefaultCurrency(currency),
          onExchangeRateChanged: (rate) => _updateExchangeRate(currency, rate),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: InkWell(
              onTap: () => _openFormModal(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFormModal({Currency? currency}) {
    setState(() {
      _editingCurrency = currency;
      _showFormModal = true;
    });

    final state = context.read<CurrenciesBloc>().state;
    final hasDefaultCurrency = state is CurrenciesLoaded &&
        state.currencies.any((c) => c.isDefault);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => FuturisticCurrencyFormModal(
        currency: currency,
        hasDefaultCurrency: hasDefaultCurrency,
        onSave: (updatedCurrency) {
          if (currency != null) {
            context.read<CurrenciesBloc>().add(
              UpdateCurrencyEvent(
                currency: updatedCurrency,
                oldCode: currency.code,
              ),
            );
          } else {
            context.read<CurrenciesBloc>().add(
              AddCurrencyEvent(currency: updatedCurrency),
            );
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
          setState(() {
            _showFormModal = false;
            _editingCurrency = null;
          });
        },
      ),
    );
  }

  void _confirmDelete(Currency currency) {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _buildConfirmDialog(
        title: 'تأكيد الحذف',
        message: 'هل أنت متأكد من حذف العملة ${currency.arabicName}؟',
        confirmLabel: 'حذف',
        confirmColor: AppTheme.error,
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<CurrenciesBloc>().add(
            DeleteCurrencyEvent(code: currency.code),
          );
        },
      ),
    );
  }

  void _setDefaultCurrency(Currency currency) {
    HapticFeedback.mediumImpact();
    
    context.read<CurrenciesBloc>().add(
      SetDefaultCurrencyEvent(code: currency.code),
    );
  }

  void _updateExchangeRate(Currency currency, double rate) {
    context.read<CurrenciesBloc>().add(
      UpdateExchangeRateEvent(code: currency.code, rate: rate),
    );
  }

  Widget _buildConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.9),
                  AppTheme.darkCard.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: confirmColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: confirmColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.success.withOpacity(0.9),
                AppTheme.success.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.error.withOpacity(0.9),
                AppTheme.error.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Particle class for animation
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

// Particle painter
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

// Grid painter for background
class _GridPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  _GridPainter({
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