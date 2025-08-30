import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../utils/service_icons.dart';

/// 🎨 Service Icon Picker Dialog
class ServiceIconPicker extends StatefulWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;

  const ServiceIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<ServiceIconPicker> createState() => _ServiceIconPickerState();
}

class _ServiceIconPickerState extends State<ServiceIconPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  
  List<ServiceIconData> _filteredIcons = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _filterIcons();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _filterIcons() {
    setState(() {
      List<ServiceIconData> icons = ServiceIcons.icons;
      
      // Filter by category
      if (_selectedCategory != 'الكل') {
        icons = ServiceIcons.filterByCategory(_selectedCategory);
      }
      
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        icons = icons.where((icon) {
          return icon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 icon.label.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
      
      _filteredIcons = icons;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.95),
                AppTheme.darkCard.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildCategoryTabs(),
                  Expanded(
                    child: _buildIconGrid(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'اختر أيقونة للخدمة',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        decoration: InputDecoration(
          hintText: 'ابحث عن أيقونة...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textMuted),
          filled: true,
          fillColor: AppTheme.darkSurface.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
          ),
        ),
        onChanged: (value) {
          _searchQuery = value;
          _filterIcons();
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ServiceIcons.getCategories();
    
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _selectedCategory = category;
              _filterIcons();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.darkSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.5)
                      : AppTheme.darkBorder.withOpacity(0.2),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Text(
                category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconGrid() {
    if (_filteredIcons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أيقونات مطابقة للبحث',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _filteredIcons.length,
      itemBuilder: (context, index) {
        final iconData = _filteredIcons[index];
        final isSelected = widget.selectedIcon == iconData.name;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onIconSelected(iconData.name);
            Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.darkSurface.withOpacity(0.3),
                        AppTheme.darkSurface.withOpacity(0.2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.darkBorder.withOpacity(0.2),
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData.icon,
                  color: isSelected ? Colors.white : AppTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  iconData.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}