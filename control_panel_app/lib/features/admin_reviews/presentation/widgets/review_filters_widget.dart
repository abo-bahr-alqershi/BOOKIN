// lib/features/admin_reviews/presentation/widgets/review_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';

class ReviewFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  
  const ReviewFiltersWidget({
    super.key,
    required this.onFilterChanged,
  });
  
  @override
  State<ReviewFiltersWidget> createState() => _ReviewFiltersWidgetState();
}

class _ReviewFiltersWidgetState extends State<ReviewFiltersWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  
  // Filter values
  String _searchQuery = '';
  double? _minRating;
  bool? _isPending;
  bool? _hasResponse;
  String _dateRange = 'all';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
      _applyFilters();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _applyFilters() {
    widget.onFilterChanged({
      'search': _searchQuery,
      'minRating': _minRating,
      'isPending': _isPending,
      'hasResponse': _hasResponse,
      'dateRange': _dateRange,
    });
  }
  
  void _clearFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _minRating = null;
      _isPending = null;
      _hasResponse = null;
      _dateRange = 'all';
    });
    _applyFilters();
  }
  
  int get _activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_minRating != null) count++;
    if (_isPending != null) count++;
    if (_hasResponse != null) count++;
    if (_dateRange != 'all') count++;
    return count;
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Main Filter Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: isDesktop ? 3 : 2,
                      child: _buildSearchField(),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Quick Filters (Desktop)
                    if (isDesktop) ...[
                      _buildQuickFilter(
                        label: 'Pending',
                        isActive: _isPending == true,
                        onTap: () {
                          setState(() => _isPending = _isPending == true ? null : true);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildQuickFilter(
                        label: 'With Response',
                        isActive: _hasResponse == true,
                        onTap: () {
                          setState(() => _hasResponse = _hasResponse == true ? null : true);
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    // Expand Button
                    _buildExpandButton(),
                    
                    // Clear Button
                    if (_activeFiltersCount > 0) ...[
                      const SizedBox(width: 8),
                      _buildClearButton(),
                    ],
                  ],
                ),
              ),
              
              // Expanded Filters
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.darkBorder.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildExpandedFilters(isDesktop),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.glassDark.withOpacity(0.3),
        border: Border.all(
          color: _searchController.text.isNotEmpty
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.glowWhite.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'Search reviews...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickFilter({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isActive
              ? AppTheme.primaryGradient
              : null,
          color: isActive
              ? null
              : AppTheme.glassDark.withOpacity(0.3),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
  
  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _isExpanded = !_isExpanded);
        if (_isExpanded) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryBlue.withOpacity(0.1),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
            if (_activeFiltersCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.primaryBlue,
                ),
                child: Text(
                  '$_activeFiltersCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClearButton() {
    return GestureDetector(
      onTap: _clearFilters,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.error.withOpacity(0.1),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.clear_all,
          size: 20,
          color: AppTheme.error,
        ),
      ),
    );
  }
  
  Widget _buildExpandedFilters(bool isDesktop) {
    return Column(
      children: [
        // Rating Filter
        _buildRatingFilter(),
        
        const SizedBox(height: 16),
        
        // Status Filters
        Row(
          children: [
            Expanded(
              child: _buildStatusFilter(),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateRangeFilter(),
              ),
            ],
          ],
        ),
        
        if (!isDesktop) ...[
          const SizedBox(height: 16),
          _buildDateRangeFilter(),
        ],
      ],
    );
  }
  
  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final rating = (index + 1).toDouble();
            final isSelected = _minRating == rating;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _minRating = isSelected ? null : rating;
                  });
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? AppTheme.warning.withOpacity(0.2)
                        : AppTheme.glassDark.withOpacity(0.3),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.warning.withOpacity(0.5)
                          : AppTheme.darkBorder.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: isSelected
                            ? AppTheme.warning
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.warning
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              label: 'Pending',
              isSelected: _isPending == true,
              onTap: () {
                setState(() => _isPending = _isPending == true ? null : true);
                _applyFilters();
              },
            ),
            _buildChip(
              label: 'Approved',
              isSelected: _isPending == false,
              onTap: () {
                setState(() => _isPending = _isPending == false ? null : false);
                _applyFilters();
              },
            ),
            _buildChip(
              label: 'Has Response',
              isSelected: _hasResponse == true,
              onTap: () {
                setState(() => _hasResponse = _hasResponse == true ? null : true);
                _applyFilters();
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDateRangeFilter() {
    final ranges = {
      'all': 'All Time',
      'today': 'Today',
      'week': 'This Week',
      'month': 'This Month',
      'year': 'This Year',
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.glassDark.withOpacity(0.3),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: DropdownButton<String>(
            value: _dateRange,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppTheme.darkCard,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textMuted,
            ),
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textWhite,
            ),
            items: ranges.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _dateRange = value);
                _applyFilters();
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildChip({
    required String label,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.glassDark.withOpacity(0.3),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}