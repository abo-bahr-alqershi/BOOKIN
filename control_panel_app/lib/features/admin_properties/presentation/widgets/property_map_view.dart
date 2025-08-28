// lib/features/admin_properties/presentation/widgets/property_map_view.dart

import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bookn_cp_app/core/theme/app_colors.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class PropertyMapView extends StatefulWidget {
  final Function(double lat, double lng)? onLocationSelected;
  final (double, double)? initialLocation; // will replace record with a class/tuple
  final bool isReadOnly;
  
  const PropertyMapView({
    super.key,
    this.onLocationSelected,
    this.initialLocation,
    this.isReadOnly = false,
  });
  
  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    if (widget.initialLocation != null) {
      final initial = widget.initialLocation!;
      // Accessing records like this requires records feature; fallback by copying to locals
      final double lat = initial.$1;
      final double lng = initial.$2;
      _selectedLocation = LatLng(lat, lng);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation ?? LatLng(15.3694, 44.1910), // Yemen
            initialZoom: 10,
            onTap: widget.isReadOnly
                ? null
                : (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                    widget.onLocationSelected?.call(point.latitude, point.longitude);
                  },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primaryBlue,
                        size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
        
        // Map Controls
        if (!widget.isReadOnly)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'انقر على الخريطة لتحديد الموقع',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ),
      ],
    );
  }
}