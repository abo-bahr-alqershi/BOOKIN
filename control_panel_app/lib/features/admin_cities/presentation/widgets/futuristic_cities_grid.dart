import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/city.dart';

class FuturisticCitiesGrid extends StatefulWidget {
  final List<City> cities;
  final Function(City) onCityTap;
  final Function(City) onEditTap;
  final Function(City) onDeleteTap;

  const FuturisticCitiesGrid({
    super.key,
    required this.cities,
    required this.onCityTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  State<FuturisticCitiesGrid> createState() => _FuturisticCitiesGridState();
}

class _FuturisticCitiesGridState extends State<FuturisticCitiesGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceMedium,
          mainAxisSpacing: AppDimensions.spaceMedium,
          childAspectRatio: 0.85,
        ),
        itemCount: widget.cities.length,
        itemBuilder: (context, index) {
          final city = widget.cities[index];
          return _CityGridCard(
            city: city,
            onTap: () => widget.onCityTap(city),
            onEditTap: () => widget.onEditTap(city),
            onDeleteTap: () => widget.onDeleteTap(city),
            animationDelay: Duration(milliseconds: index * 50),
          );
        },
      ),
    );
  }
}

class _CityGridCard extends StatefulWidget {
  final City city;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final Duration animationDelay;

  const _CityGridCard({
    required this.city,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.animationDelay,
  });

  @override
  State<_CityGridCard> createState() => _CityGridCardState();
}

class _CityGridCardState extends State<_CityGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, _isHovered ? -5.0 : 0.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isHovered
                          ? [
                              AppTheme.primaryBlue.withOpacity(0.1),
                              AppTheme.primaryPurple.withOpacity(0.05),
                            ]
                          : [
                              AppTheme.darkCard.withOpacity(0.7),
                              AppTheme.darkCard.withOpacity(0.5),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? AppTheme.primaryBlue.withOpacity(0.5)
                          : AppTheme.darkBorder.withOpacity(0.3),
                      width: _isHovered ? 2 : 1,
                    ),
                    boxShadow: [
                      if (_isHovered)
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildContent() {
    return Stack(
      children: [
        // Background Image
        if (widget.city.images.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                widget.city.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.darkCard,
                  );
                },
              ),
            ),
          ),
        
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.darkBackground.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    onTap: widget.onEditTap,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete_rounded,
                    onTap: widget.onDeleteTap,
                    isDelete: true,
                  ),
                ],
              ),
              
              const Spacer(),
              
              // City Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceMedium),
              
              // City Name
              Text(
                widget.city.name,
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Country
              Row(
                children: [
                  Icon(
                    Icons.public_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.city.country,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceSmall),
              
              // Stats
              Row(
                children: [
                  _buildStat(
                    icon: Icons.image_rounded,
                    value: widget.city.images.length.toString(),
                  ),
                  const SizedBox(width: 12),
                  if (widget.city.propertiesCount != null)
                    _buildStat(
                      icon: Icons.home_rounded,
                      value: widget.city.propertiesCount.toString(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (isDelete ? AppTheme.error : AppTheme.primaryBlue)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDelete ? AppTheme.error : AppTheme.primaryBlue)
                .withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDelete ? AppTheme.error : AppTheme.primaryBlue,
        ),
      ),
    );
  }
  
  Widget _buildStat({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}