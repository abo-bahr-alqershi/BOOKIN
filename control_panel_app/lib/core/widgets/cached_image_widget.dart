import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bookn_cp_app/injection_container.dart';
import 'package:bookn_cp_app/services/local_storage_service.dart';
import '../constants/storage_constants.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../utils/image_utils.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showLoadingIndicator;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BlendMode? colorBlendMode;
  final Color? color;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.boxShadow,
    this.gradient,
    this.colorBlendMode,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.darkCard,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ImageUtils.resolveUrl(imageUrl),
              fit: fit,
              width: width,
              height: height,
              color: color,
              colorBlendMode: colorBlendMode,
              httpHeaders: _buildAuthHeaders(),
              placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
              errorWidget: (context, url, error) => 
                errorWidget ?? _buildErrorWidget(),
            ),
            if (gradient != null)
              Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, String>? _buildAuthHeaders() {
    try {
      final local = sl<LocalStorageService>();
      final token = local.getData(StorageConstants.accessToken) as String?;
      if (token != null && token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (_) {}
    return null;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.shimmer.withValues(alpha: 0.1),
      child: showLoadingIndicator
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppTheme.darkCard,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }
}