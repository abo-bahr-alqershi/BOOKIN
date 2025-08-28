// lib/features/admin_properties/presentation/widgets/amenity_selector_widget.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
import '../bloc/amenities/amenities_bloc.dart';

class AmenitySelectorWidget extends StatefulWidget {
  final List<String> selectedAmenities;
  final Function(List<String>) onAmenitiesChanged;
  final bool isReadOnly;
  
  const AmenitySelectorWidget({
    super.key,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
    this.isReadOnly = false,
  });
  
  @override
  State<AmenitySelectorWidget> createState() => _AmenitySelectorWidgetState();
}

class _AmenitySelectorWidgetState extends State<AmenitySelectorWidget> {
  @override
  void initState() {
    super.initState();
    _loadAmenities();
  }
  
  void _loadAmenities() {
    context.read<AmenitiesBloc>().add(const LoadAmenitiesEvent());
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmenitiesBloc, AmenitiesState>(
      builder: (context, state) {
        if (state is AmenitiesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is AmenitiesLoaded) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.amenities.map((amenity) {
              final isSelected = widget.selectedAmenities.contains(amenity.id);
              
              return GestureDetector(
                onTap: widget.isReadOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        final newSelection = [...widget.selectedAmenities];
                        if (isSelected) {
                          newSelection.remove(amenity.id);
                        } else {
                          newSelection.add(amenity.id);
                        }
                        widget.onAmenitiesChanged(newSelection);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppTheme.darkCard.withValues(alpha: 0.5),
                              AppTheme.darkCard.withValues(alpha: 0.3),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                          : AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppTheme.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        amenity.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? Colors.white : AppTheme.textLight,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}