// lib/features/admin_cities/presentation/widgets/city_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class CitySearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialValue;
  
  const CitySearchBar({
    super.key,
    required this.onSearch,
    this.initialValue,
  });
  
  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  Timer? _debounce;
  bool _isFocused = false;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    
    _hasText = _controller.text.isNotEmpty;
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _onTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(_controller.text);
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
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
          scale: _scaleAnimation.value,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (_isFocused)
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(
                      0.2 * _glowAnimation.value,
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _isFocused ? 20 : 10,
                  sigmaY: _isFocused ? 20 : 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkCard.withOpacity(_isFocused ? 0.8 : 0.5),
                        AppTheme.darkCard.withOpacity(_isFocused ? 0.6 : 0.3),
                      ],
                    ),
                    border: Border.all(
                      color: _isFocused
                          ? AppTheme.primaryBlue.withOpacity(0.5)
                          : AppTheme.darkBorder.withOpacity(0.2),
                      width: _isFocused ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search Icon with Animation
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _isFocused
                                ? AppTheme.primaryBlue.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: _isFocused
                                ? AppTheme.primaryBlue
                                : AppTheme.textMuted.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ),
                      
                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                            hintText: 'البحث عن مدينة...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.textMuted.withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (value) {
                            widget.onSearch(value);
                          },
                        ),
                      ),
                      
                      // Clear Button
                      if (_hasText)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _controller.clear();
                              widget.onSearch('');
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.textMuted.withOpacity(0.2),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppTheme.textMuted.withOpacity(0.8),
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      
                      // Voice Search Button
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Implement voice search
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryPurple.withOpacity(0.2),
                                  AppTheme.primaryViolet.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.mic_none_rounded,
                              color: AppTheme.primaryPurple,
                              size: 18,
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
        );
      },
    );
  }
}