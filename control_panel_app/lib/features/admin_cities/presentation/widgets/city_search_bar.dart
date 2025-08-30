import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class CitySearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onFilter;

  const CitySearchBar({
    super.key,
    required this.onSearch,
    this.onFilter,
  });

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutExpo,
    ));
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _widthAnimation.value,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFocused
                    ? [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.05),
                      ]
                    : [
                        AppTheme.darkCard.withOpacity(0.5),
                        AppTheme.darkCard.withOpacity(0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused
                    ? AppTheme.primaryBlue.withOpacity(0.5)
                    : AppTheme.darkBorder.withOpacity(0.3),
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    // Search Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused
                            ? AppTheme.primaryBlue
                            : AppTheme.textMuted,
                        size: 24,
                      ),
                    ),
                    
                    // Search Input
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن المدن...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textMuted.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: widget.onSearch,
                      ),
                    ),
                    
                    // Clear Button
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _searchController.clear();
                          widget.onSearch('');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.clear_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    
                    // Filter Button
                    if (widget.onFilter != null)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onFilter!();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}