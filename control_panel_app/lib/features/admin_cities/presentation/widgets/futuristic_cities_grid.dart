// lib/features/admin_cities/presentation/widgets/futuristic_cities_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/entities/city.dart';
import 'futuristic_city_card.dart';

class FuturisticCitiesGrid extends StatelessWidget {
  final List<City> cities;
  final bool isGridView;
  final bool isDesktop;
  final bool isTablet;
  final Function(City)? onEdit;
  final Function(City)? onDelete;
  final Function(City)? onImageTap;
  
  const FuturisticCitiesGrid({
    super.key,
    required this.cities,
    required this.isGridView,
    required this.isDesktop,
    required this.isTablet,
    this.onEdit,
    this.onDelete,
    this.onImageTap,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
          childAspectRatio: isDesktop ? 0.85 : (isTablet ? 0.8 : 0.75),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: isDesktop ? 4 : (isTablet ? 3 : 2),
              child: ScaleAnimation(
                scale: 0.95,
                child: FadeInAnimation(
                  child: FuturisticCityCard(
                    city: cities[index],
                    isGridView: true,
                    onEdit: onEdit != null ? () => onEdit!(cities[index]) : null,
                    onDelete: onDelete != null ? () => onDelete!(cities[index]) : null,
                    onImageTap: onImageTap != null ? () => onImageTap!(cities[index]) : null,
                    onTap: () {
                      // Navigate to city details
                    },
                  ),
                ),
              ),
            );
          },
          childCount: cities.length,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: FuturisticCityCard(
                    city: cities[index],
                    isGridView: false,
                    onEdit: onEdit != null ? () => onEdit!(cities[index]) : null,
                    onDelete: onDelete != null ? () => onDelete!(cities[index]) : null,
                    onImageTap: onImageTap != null ? () => onImageTap!(cities[index]) : null,
                    onTap: () {
                      // Navigate to city details
                    },
                  ),
                ),
              ),
            );
          },
          childCount: cities.length,
        ),
      );
    }
  }
}