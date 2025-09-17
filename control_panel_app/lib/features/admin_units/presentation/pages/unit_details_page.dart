// // lib/features/admin_units/presentation/pages/unit_details_page.dart

// import 'package:bookn_cp_app/core/theme/app_theme.dart';
// import 'package:bookn_cp_app/features/admin_units/domain/entities/money.dart';
// import 'package:bookn_cp_app/features/admin_units/domain/entities/pricing_method.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:ui';
// import 'dart:math' as math;
// import 'package:bookn_cp_app/core/theme/app_colors.dart';
// import 'package:bookn_cp_app/core/theme/app_text_styles.dart';
// import '../bloc/unit_details/unit_details_bloc.dart';
// import '../../domain/entities/unit.dart';
// import '../../domain/entities/unit_field_value.dart';
// import '../widgets/unit_image_gallery.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// class UnitDetailsPage extends StatefulWidget {
//   final String unitId;

//   const UnitDetailsPage({
//     super.key,
//     required this.unitId,
//   });

//   @override
//   State<UnitDetailsPage> createState() => _UnitDetailsPageState();
// }

// class _UnitDetailsPageState extends State<UnitDetailsPage>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _backgroundAnimationController;
//   late AnimationController _glowController;
//   late AnimationController _contentAnimationController;
//   late AnimationController _floatingButtonController;
//   late AnimationController _parallaxController;

//   // Animations
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _parallaxAnimation;

//   // Scroll Controller
//   final ScrollController _scrollController = ScrollController();
//   double _scrollOffset = 0.0;
//   bool _showFloatingHeader = false;

//   // Tab Controller
//   late TabController _tabController;
//   int _currentTabIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadUnitDetails();
//     _setupScrollListener();
//   }

//   void _initializeAnimations() {
//     // Background Animation
//     _backgroundAnimationController = AnimationController(
//       duration: const Duration(seconds: 30),
//       vsync: this,
//     )..repeat();

//     // Glow Animation
//     _glowController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);

//     _glowAnimation = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     // Content Animation
//     _contentAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _contentAnimationController,
//       curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _contentAnimationController,
//       curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//     ));

//     _scaleAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _contentAnimationController,
//       curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
//     ));

//     // Floating Button Animation
//     _floatingButtonController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     // Parallax Animation
//     _parallaxController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _parallaxAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _parallaxController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Tab Controller
//     _tabController = TabController(
//       length: 4,
//       vsync: this,
//     );

//     _tabController.addListener(() {
//       setState(() {
//         _currentTabIndex = _tabController.index;
//       });
//     });

//     // Start animations
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) {
//         _contentAnimationController.forward();
//         _floatingButtonController.forward();
//       }
//     });
//   }

//   void _setupScrollListener() {
//     _scrollController.addListener(() {
//       setState(() {
//         _scrollOffset = _scrollController.offset;
//         _showFloatingHeader = _scrollOffset > 200;
//       });

//       // Update parallax
//       if (_scrollOffset > 0 && _scrollOffset < 300) {
//         _parallaxController.value = _scrollOffset / 300;
//       }
//     });
//   }

//   void _loadUnitDetails() {
//     context
//         .read<UnitDetailsBloc>()
//         .add(LoadUnitDetailsEvent(unitId: widget.unitId));
//   }

//   @override
//   void dispose() {
//     _backgroundAnimationController.dispose();
//     _glowController.dispose();
//     _contentAnimationController.dispose();
//     _floatingButtonController.dispose();
//     _parallaxController.dispose();
//     _scrollController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<UnitDetailsBloc, UnitDetailsState>(
//       listener: (context, state) {
//         if (state is UnitDeleted) {
//           _showSuccessMessage('تم حذف الوحدة بنجاح');
//           context.pop();
//         } else if (state is UnitDetailsError) {
//           _showErrorMessage(state.message);
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: AppTheme.darkBackground,
//           body: Stack(
//             children: [
//               // Animated Background
//               _buildAnimatedBackground(),

//               // Main Content
//               if (state is UnitDetailsLoaded)
//                 _buildLoadedContent(state.unit)
//               else if (state is UnitDetailsLoading)
//                 _buildLoadingState()
//               else if (state is UnitDetailsError)
//                 _buildErrorState(state.message),

//               // Floating Header (appears on scroll)
//               if (_showFloatingHeader && state is UnitDetailsLoaded)
//                 _buildFloatingHeader(state.unit),

//               // Floating Action Buttons
//               if (state is UnitDetailsLoaded)
//                 _buildFloatingActionButtons(state.unit),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAnimatedBackground() {
//     return AnimatedBuilder(
//       animation:
//           Listenable.merge([_backgroundAnimationController, _glowAnimation]),
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppTheme.darkBackground,
//                 AppTheme.darkBackground2.withOpacity(0.8),
//                 AppTheme.darkBackground3.withOpacity(0.6),
//               ],
//             ),
//           ),
//           child: CustomPaint(
//             painter: _AdvancedBackgroundPainter(
//               animation: _backgroundAnimationController.value,
//               glowIntensity: _glowAnimation.value,
//             ),
//             size: Size.infinite,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoadedContent(Unit unit) {
//     return CustomScrollView(
//       controller: _scrollController,
//       physics: const BouncingScrollPhysics(),
//       slivers: [
//         // Hero Image Header
//         _buildSliverHeader(unit),

//         // Unit Info Card
//         SliverToBoxAdapter(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: _buildUnitInfoCard(unit),
//               ),
//             ),
//           ),
//         ),

//         // Tabs Section
//         SliverPersistentHeader(
//           pinned: true,
//           delegate: _TabBarDelegate(
//             tabController: _tabController,
//             currentIndex: _currentTabIndex,
//           ),
//         ),

//         // Tab Content
//         SliverToBoxAdapter(
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: _buildTabContent(unit),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSliverHeader(Unit unit) {
//     final hasImages = unit.images?.isNotEmpty ?? false;

//     return SliverAppBar(
//       expandedHeight: 400,
//       pinned: false,
//       backgroundColor: Colors.transparent,
//       leading: _buildBackButton(),
//       actions: [
//         _buildShareButton(),
//         const SizedBox(width: 8),
//         _buildGalleryButton(),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Image or Gradient Placeholder
//             if (hasImages)
//               Hero(
//                 tag: 'unit-image-${unit.id}',
//                 child: _buildHeaderImage(unit.images!.first),
//               )
//             else
//               _buildGradientPlaceholder(),

//             // Gradient Overlay
//             _buildGradientOverlay(),

//             // Unit Basic Info
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: _buildHeaderInfo(unit),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderImage(String imageUrl) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         CachedNetworkImage(
//           imageUrl: imageUrl,
//           fit: BoxFit.cover,
//           placeholder: (context, url) => Container(
//             color: AppTheme.darkCard.withOpacity(0.5),
//             child: Center(
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   AppTheme.primaryBlue.withOpacity(0.5),
//                 ),
//               ),
//             ),
//           ),
//           errorWidget: (context, url, error) => _buildGradientPlaceholder(),
//         ),

//         // Parallax Effect
//         AnimatedBuilder(
//           animation: _parallaxAnimation,
//           builder: (context, child) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black
//                         .withOpacity(0.1 + (0.2 * _parallaxAnimation.value)),
//                     Colors.transparent,
//                     Colors.black
//                         .withOpacity(0.3 + (0.3 * _parallaxAnimation.value)),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildGradientPlaceholder() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.primaryBlue.withOpacity(0.3),
//             AppTheme.primaryPurple.withOpacity(0.2),
//             AppTheme.primaryViolet.withOpacity(0.1),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Icon(
//           Icons.apartment_rounded,
//           size: 80,
//           color: AppTheme.textWhite.withOpacity(0.3),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.black.withOpacity(0.1),
//             Colors.black.withOpacity(0.6),
//             Colors.black.withOpacity(0.8),
//           ],
//           stops: const [0.0, 0.4, 0.7, 1.0],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderInfo(Unit unit) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppTheme.darkCard.withOpacity(0.5),
//                 AppTheme.darkCard.withOpacity(0.3),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: AppTheme.darkBorder.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Unit Name
//               Text(
//                 unit.name,
//                 style: AppTextStyles.heading1.copyWith(
//                   color: AppTheme.textWhite,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black.withOpacity(0.5),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Property & Type
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_city_rounded,
//                     size: 16,
//                     color: AppTheme.primaryBlue,
//                   ),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       '${unit.propertyName} • ${unit.unitTypeName}',
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: AppTheme.textLight,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Price & Status Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Price
//                   _buildPriceTag(unit.basePrice, unit.pricingMethod),

//                   // Status
//                   _buildStatusBadge(unit.isAvailable),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceTag(Money price, PricingMethod method) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryBlue.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             price.displayAmount,
//             style: AppTextStyles.heading3.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             method.arabicLabel,
//             style: AppTextStyles.caption.copyWith(
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(bool isAvailable) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: isAvailable
//             ? AppTheme.success.withOpacity(0.2)
//             : AppTheme.warning.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isAvailable
//               ? AppTheme.success.withOpacity(0.5)
//               : AppTheme.warning.withOpacity(0.5),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(
//               color: isAvailable ? AppTheme.success : AppTheme.warning,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             isAvailable ? 'متاحة' : 'محجوزة',
//             style: AppTextStyles.caption.copyWith(
//               color: isAvailable ? AppTheme.success : AppTheme.warning,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUnitInfoCard(Unit unit) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.darkCard.withOpacity(0.7),
//             AppTheme.darkCard.withOpacity(0.5),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.3),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryBlue.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Stats Row
//           _buildStatsRow(unit),

//           const SizedBox(height: 20),
//           const Divider(height: 1),
//           const SizedBox(height: 20),

//           // Quick Info Grid
//           _buildQuickInfoGrid(unit),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsRow(Unit unit) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildStatItem(
//           icon: Icons.visibility_rounded,
//           value: unit.viewCount.toString(),
//           label: 'مشاهدة',
//           color: AppTheme.primaryCyan,
//         ),
//         _buildStatItem(
//           icon: Icons.calendar_month_rounded,
//           value: unit.bookingCount.toString(),
//           label: 'حجز',
//           color: AppTheme.primaryPurple,
//         ),
//         _buildStatItem(
//           icon: Icons.star_rounded,
//           value: '4.8',
//           label: 'تقييم',
//           color: AppTheme.warning,
//         ),
//         _buildStatItem(
//           icon: Icons.favorite_rounded,
//           value: '32',
//           label: 'مفضلة',
//           color: AppTheme.error,
//         ),
//       ],
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 24,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: AppTextStyles.heading3.copyWith(
//             color: AppTheme.textWhite,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: AppTextStyles.caption.copyWith(
//             color: AppTheme.textMuted,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickInfoGrid(Unit unit) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildInfoTile(
//                 icon: Icons.people_rounded,
//                 title: 'السعة',
//                 value: unit.capacityDisplay.isNotEmpty
//                     ? unit.capacityDisplay
//                     : '${unit.maxCapacity} أشخاص',
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildInfoTile(
//                 icon: Icons.discount_rounded,
//                 title: 'الخصم',
//                 value: unit.discountPercentage > 0
//                     ? '${unit.discountPercentage}%'
//                     : 'لا يوجد',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         if (unit.distanceKm != null)
//           _buildInfoTile(
//             icon: Icons.location_on_rounded,
//             title: 'المسافة',
//             value: '${unit.distanceKm} كم',
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoTile({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppTheme.darkSurface.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: AppTheme.primaryBlue,
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppTheme.textMuted,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppTheme.textWhite,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabContent(Unit unit) {
//     switch (_currentTabIndex) {
//       case 0:
//         return _buildDetailsTab(unit);
//       case 1:
//         return _buildGalleryTab(unit);
//       case 2:
//         return _buildFeaturesTab(unit);
//       case 3:
//         return _buildReviewsTab(unit);
//       default:
//         return _buildDetailsTab(unit);
//     }
//   }

//   Widget _buildDetailsTab(Unit unit) {
//     return AnimationLimiter(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: AnimationConfiguration.toStaggeredList(
//             duration: const Duration(milliseconds: 375),
//             childAnimationBuilder: (widget) => SlideAnimation(
//               verticalOffset: 50.0,
//               child: FadeInAnimation(child: widget),
//             ),
//             children: [
//               // Description Section
//               _buildSectionTitle('الوصف', Icons.description_rounded),
//               const SizedBox(height: 12),
//               _buildDescriptionCard(unit.customFeatures),

//               const SizedBox(height: 24),

//               // Dynamic Fields Section
//               if (unit.dynamicFields.isNotEmpty) ...[
//                 _buildSectionTitle('معلومات إضافية', Icons.info_rounded),
//                 const SizedBox(height: 12),
//                 _buildDynamicFieldsCard(unit.dynamicFields),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGalleryTab(Unit unit) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('معرض الصور', Icons.photo_library_rounded),
//           const SizedBox(height: 16),

//           // Gallery Widget
//           UnitImageGallery(
//             unitId: widget.unitId,
//             isReadOnly: true,
//             maxImages: 20,
//           ),

//           // View All Button
//           if (unit.images?.isNotEmpty ?? false)
//             Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: Center(
//                 child: _buildViewAllButton(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturesTab(Unit unit) {
//     final features = unit.featuresList;

//     return AnimationLimiter(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle('المميزات', Icons.stars_rounded),
//             const SizedBox(height: 16),
//             if (features.isEmpty)
//               _buildEmptyFeatures()
//             else
//               _buildFeaturesGrid(features),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReviewsTab(Unit unit) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('التقييمات', Icons.rate_review_rounded),
//           const SizedBox(height: 16),

//           // Reviews placeholder
//           _buildNoReviewsPlaceholder(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             gradient: AppTheme.primaryGradient,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: AppTextStyles.heading2.copyWith(
//             color: AppTheme.textWhite,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionCard(String description) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.darkCard.withOpacity(0.5),
//             AppTheme.darkCard.withOpacity(0.3),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Text(
//         description.isEmpty ? 'لا يوجد وصف' : description,
//         style: AppTextStyles.bodyMedium.copyWith(
//           color: AppTheme.textLight,
//           height: 1.6,
//         ),
//       ),
//     );
//   }

//   Widget _buildDynamicFieldsCard(List<FieldGroupWithValues> fieldGroups) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.darkCard.withOpacity(0.5),
//             AppTheme.darkCard.withOpacity(0.3),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: fieldGroups.map((group) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   group.displayName,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppTheme.primaryBlue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 ...group.fieldValues.map((field) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           field.displayName ?? field.fieldName ?? '',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppTheme.textMuted,
//                           ),
//                         ),
//                         Text(
//                           field.fieldValue,
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppTheme.textLight,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildFeaturesGrid(List<String> features) {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: features.map((feature) {
//         return AnimationConfiguration.staggeredList(
//           position: features.indexOf(feature),
//           duration: const Duration(milliseconds: 375),
//           child: ScaleAnimation(
//             child: FadeInAnimation(
//               child: _buildFeatureChip(feature),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildFeatureChip(String feature) {
//     final icon = _getFeatureIcon(feature);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primaryBlue.withOpacity(0.1),
//             AppTheme.primaryPurple.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppTheme.primaryBlue.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 18,
//             color: AppTheme.primaryBlue,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             feature,
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppTheme.textWhite,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyFeatures() {
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         color: AppTheme.darkCard.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.featured_play_list_rounded,
//               size: 48,
//               color: AppTheme.textMuted.withOpacity(0.3),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'لا توجد مميزات',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppTheme.textMuted.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoReviewsPlaceholder() {
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.darkCard.withOpacity(0.3),
//             AppTheme.darkCard.withOpacity(0.2),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppTheme.darkBorder.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.rate_review_outlined,
//               size: 48,
//               color: AppTheme.textMuted.withOpacity(0.3),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'لا توجد تقييمات بعد',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppTheme.textMuted.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllButton() {
//     return GestureDetector(
//       onTap: () => _navigateToGallery(),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           gradient: AppTheme.primaryGradient,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.primaryBlue.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.photo_library_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'عرض جميع الصور',
//               style: AppTextStyles.buttonMedium.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingHeader(Unit unit) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: 80,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.darkCard.withOpacity(0.95),
//             AppTheme.darkCard.withOpacity(0.85),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryBlue.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   _buildBackButton(),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           unit.name,
//                           style: AppTextStyles.bodyMedium.copyWith(
//                             color: AppTheme.textWhite,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           unit.propertyName,
//                           style: AppTextStyles.caption.copyWith(
//                             color: AppTheme.textMuted,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                   _buildShareButton(),
//                   const SizedBox(width: 8),
//                   _buildGalleryButton(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButtons(Unit unit) {
//     return Positioned(
//       bottom: 24,
//       right: 24,
//       child: ScaleTransition(
//         scale: CurvedAnimation(
//           parent: _floatingButtonController,
//           curve: Curves.elasticOut,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildFloatingButton(
//               icon: Icons.edit_rounded,
//               color: AppTheme.primaryBlue,
//               onTap: () => _navigateToEdit(unit.id),
//             ),
//             const SizedBox(height: 12),
//             _buildFloatingButton(
//               icon: Icons.delete_rounded,
//               color: AppTheme.error,
//               onTap: () => _showDeleteConfirmation(unit),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.mediumImpact();
//         onTap();
//       },
//       child: Container(
//         width: 56,
//         height: 56,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               color,
//               color.withOpacity(0.8),
//             ],
//           ),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }

//   Widget _buildBackButton() {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         context.pop();
//       },
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppTheme.darkCard.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: AppTheme.darkBorder.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: const Icon(
//           Icons.arrow_back_rounded,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildShareButton() {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         // Implement share functionality
//       },
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppTheme.darkCard.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: AppTheme.darkBorder.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: const Icon(
//           Icons.share_rounded,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildGalleryButton() {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         _navigateToGallery();
//       },
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppTheme.darkCard.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: AppTheme.darkBorder.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: const Icon(
//           Icons.photo_library_rounded,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: AppTheme.primaryGradient,
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 strokeWidth: 3,
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'جاري تحميل البيانات...',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppTheme.textMuted,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline_rounded,
//             size: 80,
//             color: AppTheme.error.withOpacity(0.7),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppTheme.error,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           GestureDetector(
//             onTap: _loadUnitDetails,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradient,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Text(
//                 'إعادة المحاولة',
//                 style: AppTextStyles.buttonMedium.copyWith(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   IconData _getFeatureIcon(String feature) {
//     final featureLower = feature.toLowerCase();
//     if (featureLower.contains('واي فاي') || featureLower.contains('wifi')) {
//       return Icons.wifi_rounded;
//     } else if (featureLower.contains('تكييف') || featureLower.contains('ac')) {
//       return Icons.ac_unit_rounded;
//     } else if (featureLower.contains('مطبخ')) {
//       return Icons.kitchen_rounded;
//     } else if (featureLower.contains('موقف') ||
//         featureLower.contains('parking')) {
//       return Icons.local_parking_rounded;
//     } else if (featureLower.contains('مسبح') || featureLower.contains('pool')) {
//       return Icons.pool_rounded;
//     } else if (featureLower.contains('جيم') || featureLower.contains('gym')) {
//       return Icons.fitness_center_rounded;
//     } else {
//       return Icons.check_circle_rounded;
//     }
//   }

//   void _navigateToEdit(String unitId) {
//     context.push('/admin/units/$unitId/edit');
//   }

//   void _navigateToGallery() {
//     final state = context.read<UnitDetailsBloc>().state;
//     if (state is UnitDetailsLoaded) {
//       context.go(
//         '/admin/units/${widget.unitId}/gallery',
//         extra: state.unit,
//       );
//     }
//   }

//   void _showDeleteConfirmation(Unit unit) {
//     showDialog(
//       context: context,
//       builder: (context) => _DeleteConfirmationDialog(
//         unitName: unit.name,
//         onConfirm: () {
//           Navigator.pop(context);
//           context.read<UnitDetailsBloc>().add(
//                 DeleteUnitDetailsEvent(unitId: unit.id),
//               );
//         },
//       ),
//     );
//   }

//   void _showSuccessMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.check_circle_rounded,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(message),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.success,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.error_outline_rounded,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(message),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }

// // Tab Bar Delegate
// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabController tabController;
//   final int currentIndex;

//   _TabBarDelegate({
//     required this.tabController,
//     required this.currentIndex,
//   });

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         color: AppTheme.darkBackground.withOpacity(0.95),
//         border: Border(
//           bottom: BorderSide(
//             color: AppTheme.darkBorder.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: TabBar(
//             controller: tabController,
//             isScrollable: false,
//             indicatorSize: TabBarIndicatorSize.label,
//             indicator: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: AppTheme.primaryGradient,
//             ),
//             indicatorPadding:
//                 const EdgeInsets.symmetric(horizontal: -20, vertical: 8),
//             labelColor: Colors.white,
//             unselectedLabelColor: AppTheme.textMuted,
//             labelStyle: AppTextStyles.bodyMedium.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             tabs: [
//               _buildTab('التفاصيل', Icons.info_rounded, currentIndex == 0),
//               _buildTab(
//                   'الصور', Icons.photo_library_rounded, currentIndex == 1),
//               _buildTab('المميزات', Icons.stars_rounded, currentIndex == 2),
//               _buildTab(
//                   'التقييمات', Icons.rate_review_rounded, currentIndex == 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String label, IconData icon, bool isSelected) {
//     return Tab(
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: isSelected ? Colors.white : AppTheme.textMuted,
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : AppTheme.textMuted,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 60;

//   @override
//   double get minExtent => 60;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       true;
// }

// // Delete Confirmation Dialog
// class _DeleteConfirmationDialog extends StatelessWidget {
//   final String unitName;
//   final VoidCallback onConfirm;

//   const _DeleteConfirmationDialog({
//     required this.unitName,
//     required this.onConfirm,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppTheme.darkCard.withOpacity(0.95),
//               AppTheme.darkCard.withOpacity(0.85),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: AppTheme.error.withOpacity(0.3),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.error.withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppTheme.error.withOpacity(0.2),
//                     AppTheme.error.withOpacity(0.1),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.warning_rounded,
//                 color: AppTheme.error,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'تأكيد الحذف',
//               style: AppTextStyles.heading3.copyWith(
//                 color: AppTheme.textWhite,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'هل أنت متأكد من حذف "$unitName"؟\nلا يمكن التراجع عن هذا الإجراء.',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppTheme.textMuted,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: AppTheme.darkSurface.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: AppTheme.darkBorder.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'إلغاء',
//                           style: AppTextStyles.buttonMedium.copyWith(
//                             color: AppTheme.textMuted,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       HapticFeedback.mediumImpact();
//                       onConfirm();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppTheme.error,
//                             AppTheme.error.withOpacity(0.8),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.error.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           'حذف',
//                           style: AppTextStyles.buttonMedium.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Advanced Background Painter
// class _AdvancedBackgroundPainter extends CustomPainter {
//   final double animation;
//   final double glowIntensity;

//   _AdvancedBackgroundPainter({
//     required this.animation,
//     required this.glowIntensity,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     // Draw animated gradient circles
//     for (int i = 0; i < 3; i++) {
//       final progress = (animation + i * 0.33) % 1.0;
//       final radius = 200 + (100 * math.sin(progress * math.pi * 2));
//       final opacity = 0.03 + (0.02 * glowIntensity);

//       paint.shader = RadialGradient(
//         colors: [
//           AppTheme.primaryBlue.withOpacity(opacity),
//           AppTheme.primaryPurple.withOpacity(opacity * 0.5),
//           Colors.transparent,
//         ],
//       ).createShader(Rect.fromCircle(
//         center: Offset(
//           size.width * (0.3 + 0.4 * math.cos(progress * math.pi * 2)),
//           size.height * (0.3 + 0.4 * math.sin(progress * math.pi * 2)),
//         ),
//         radius: radius,
//       ));

//       canvas.drawCircle(
//         Offset(
//           size.width * (0.3 + 0.4 * math.cos(progress * math.pi * 2)),
//           size.height * (0.3 + 0.4 * math.sin(progress * math.pi * 2)),
//         ),
//         radius,
//         paint,
//       );
//     }

//     // Draw grid pattern
//     paint.shader = null;
//     paint.color = AppTheme.primaryBlue.withOpacity(0.02);
//     paint.strokeWidth = 0.5;
//     paint.style = PaintingStyle.stroke;

//     const spacing = 50.0;
//     for (double x = 0; x < size.width; x += spacing) {
//       canvas.drawLine(
//         Offset(x, 0),
//         Offset(x, size.height),
//         paint,
//       );
//     }

//     for (double y = 0; y < size.height; y += spacing) {
//       canvas.drawLine(
//         Offset(0, y),
//         Offset(size.width, y),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// lib/features/admin_units/presentation/pages/unit_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/unit_details/unit_details_bloc.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_field_value.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/pricing_method.dart';
import '../widgets/unit_image_gallery.dart';
import '../widgets/unit_amenities_showcase.dart';
import '../widgets/unit_pricing_cards.dart';
import '../widgets/unit_availability_calendar.dart';

class UnitDetailsPage extends StatefulWidget {
  final String unitId;

  const UnitDetailsPage({
    super.key,
    required this.unitId,
  });

  @override
  State<UnitDetailsPage> createState() => _UnitDetailsPageState();
}

class _UnitDetailsPageState extends State<UnitDetailsPage>
    with TickerProviderStateMixin {
  // 🎭 Animation Controllers
  late AnimationController _heroAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _floatingActionsController;
  late AnimationController _tabAnimationController;
  late AnimationController _glowAnimationController;

  // 📜 Scroll Controller
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _showFloatingHeader = false;

  // 🗂️ Tab Management
  int _selectedTabIndex = 0;
  final List<_TabItem> _tabs = [
    _TabItem(
      icon: CupertinoIcons.info_circle_fill,
      label: 'معلومات',
      gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
    ),
    _TabItem(
      icon: CupertinoIcons.photo_on_rectangle,
      label: 'الصور',
      gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
    ),
    _TabItem(
      icon: CupertinoIcons.sparkles,
      label: 'المميزات',
      gradient: [AppTheme.neonPurple, AppTheme.neonBlue],
    ),
    _TabItem(
      icon: CupertinoIcons.calendar,
      label: 'التوفر',
      gradient: [AppTheme.success, AppTheme.neonGreen],
    ),
    _TabItem(
      icon: CupertinoIcons.money_dollar_circle_fill,
      label: 'الأسعار',
      gradient: [AppTheme.warning, AppTheme.neonPurple],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadUnitDetails();
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingActionsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _heroAnimationController.forward();
        _floatingActionsController.forward();
        _tabAnimationController.forward();
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
        _showFloatingHeader = _scrollOffset > 250;
      });
    });
  }

  void _loadUnitDetails() {
    context.read<UnitDetailsBloc>().add(
          LoadUnitDetailsEvent(unitId: widget.unitId),
        );
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _pulseAnimationController.dispose();
    _floatingActionsController.dispose();
    _tabAnimationController.dispose();
    _glowAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocConsumer<UnitDetailsBloc, UnitDetailsState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Stack(
            children: [
              // 🌌 Animated Background
              _buildAnimatedBackground(),

              // 📱 Main Content
              if (state is UnitDetailsLoaded)
                _buildLoadedContent(state.unit)
              else if (state is UnitDetailsLoading)
                _buildLoadingState()
              else if (state is UnitDetailsError)
                _buildErrorState(state.message)
              else
                _buildEmptyState(),

              // 🎯 Floating Header
              if (_showFloatingHeader && state is UnitDetailsLoaded)
                _buildFloatingHeader(state.unit),

              // 🎬 Floating Actions
              if (state is UnitDetailsLoaded)
                _buildFloatingActionButtons(state.unit),

              // 🎯 Quick Access Menu
              if (state is UnitDetailsLoaded) _buildQuickAccessButton(),
            ],
          );
        },
      ),
    );
  }

  // 🌌 Animated Background with Particles
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimationController,
        _pulseAnimationController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withValues(
                  alpha: 0.8 + (0.2 * _pulseAnimationController.value),
                ),
                AppTheme.darkBackground3.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _ParticleBackgroundPainter(
              animation: _glowAnimationController.value,
              pulseAnimation: _pulseAnimationController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  // 📱 Main Loaded Content
  Widget _buildLoadedContent(Unit unit) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // 🎨 Hero Header
        _buildHeroHeader(unit),

        // 📊 Stats Section
        SliverToBoxAdapter(
          child: _buildAnimatedStatsSection(unit),
        ),

        // 🎯 Quick Info Cards
        SliverToBoxAdapter(
          child: _buildQuickInfoSection(unit),
        ),

        // 🗂️ Tabs Section
        SliverPersistentHeader(
          pinned: true,
          delegate: _FuturisticTabBarDelegate(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              HapticFeedback.selectionClick();
              setState(() => _selectedTabIndex = index);
            },
          ),
        ),

        // 📋 Tab Content
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildTabContent(unit, key: ValueKey(_selectedTabIndex)),
          ),
        ),

        // Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // 🎨 Hero Header Section
  Widget _buildHeroHeader(Unit unit) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: false,
      backgroundColor: Colors.transparent,
      leading: _buildGlassBackButton(),
      actions: [
        _buildGlassActionButton(
          icon: CupertinoIcons.heart,
          onTap: () => _toggleFavorite(unit),
        ),
        const SizedBox(width: 8),
        _buildGlassActionButton(
          icon: CupertinoIcons.share,
          onTap: () => _shareUnit(unit),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image or Gradient
            _buildHeroImage(unit),

            // Multi-layer Gradient Overlay
            _buildMultiLayerGradient(),

            // Hero Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHeroInfo(unit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(Unit unit) {
    if (unit.images?.isNotEmpty ?? false) {
      return Hero(
        tag: 'unit-${unit.id}',
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImageWidget(
              imageUrl: unit.images!.first,
              fit: BoxFit.cover,
            ),
            // Parallax overlay
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final parallax = _scrollOffset * 0.5;
                return Container(
                  transform: Matrix4.translationValues(0, parallax, 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.4),
            AppTheme.primaryPurple.withValues(alpha: 0.3),
            AppTheme.primaryViolet.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.building_2_fill,
          size: 80,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildMultiLayerGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.darkBackground.withValues(alpha: 0.2),
            AppTheme.darkBackground.withValues(alpha: 0.7),
            AppTheme.darkBackground.withValues(alpha: 0.95),
          ],
          stops: const [0.3, 0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeroInfo(Unit unit) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _heroAnimationController,
          curve: const Interval(0.3, 1.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.darkBackground.withValues(alpha: 0.5),
                AppTheme.darkBackground.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkCard.withValues(alpha: 0.4),
                      AppTheme.darkCard.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit Name with glow effect
                    Text(
                      unit.name,
                      style: AppTextStyles.neonText(
                        fontSize: 28,
                        color: AppTheme.textWhite,
                      ).copyWith(
                        shadows: [
                          Shadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Property & Type
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.building_2_fill,
                          size: 16,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${unit.propertyName} • ${unit.unitTypeName}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price & Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAnimatedPriceTag(
                            unit.basePrice, unit.pricingMethod),
                        _buildAnimatedStatusBadge(unit.isAvailable),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 📊 Animated Stats Section
  Widget _buildAnimatedStatsSection(Unit unit) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 20),
      child: AnimationLimiter(
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildStatCard(
                icon: CupertinoIcons.eye_fill,
                label: 'المشاهدات',
                value: unit.viewCount.toString(),
                gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                trend: 12.5,
              ),
              _buildStatCard(
                icon: CupertinoIcons.calendar_badge_plus,
                label: 'الحجوزات',
                value: unit.bookingCount.toString(),
                gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                trend: 8.3,
              ),
              _buildStatCard(
                icon: CupertinoIcons.star_fill,
                label: 'التقييم',
                value: '4.8',
                gradient: [AppTheme.warning, AppTheme.neonPurple],
                trend: 0,
              ),
              _buildStatCard(
                icon: CupertinoIcons.chart_pie_fill,
                label: 'الإشغال',
                value: '85%',
                gradient: [AppTheme.success, AppTheme.neonGreen],
                trend: -3.2,
              ),
              _buildStatCard(
                icon: CupertinoIcons.money_dollar_circle_fill,
                label: 'الإيرادات',
                value: '12.5k',
                gradient: [AppTheme.info, AppTheme.neonBlue],
                trend: 15.7,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
    required double trend,
  }) {
    final isPositive = trend >= 0;

    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          width: 140,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(
                  alpha: 0.2 + (0.1 * _pulseAnimationController.value),
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradient.first.withValues(alpha: 0.15),
                      gradient.last.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gradient.first.withValues(alpha: 0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Icon
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Icon(
                        icon,
                        size: 80,
                        color: gradient.first.withValues(alpha: 0.1),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with trend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: gradient),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              if (trend != 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isPositive
                                            ? AppTheme.success
                                            : AppTheme.error)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isPositive
                                            ? CupertinoIcons.arrow_up_right
                                            : CupertinoIcons.arrow_down_right,
                                        size: 10,
                                        color: isPositive
                                            ? AppTheme.success
                                            : AppTheme.error,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${trend.abs()}%',
                                        style: AppTextStyles.caption.copyWith(
                                          color: isPositive
                                              ? AppTheme.success
                                              : AppTheme.error,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          // Value
                          Text(
                            value,
                            style: AppTextStyles.heading2.copyWith(
                              color: gradient.first,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Label
                          Text(
                            label,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🎯 Quick Info Section
  Widget _buildQuickInfoSection(Unit unit) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildQuickInfoCard(
                      icon: CupertinoIcons.person_2_fill,
                      title: 'السعة',
                      value: unit.capacityDisplay.isNotEmpty
                          ? unit.capacityDisplay
                          : '${unit.maxCapacity} أشخاص',
                      gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickInfoCard(
                      icon: CupertinoIcons.tag_fill,
                      title: 'الخصم',
                      value: unit.discountPercentage > 0
                          ? '${unit.discountPercentage}%'
                          : 'لا يوجد',
                      gradient: [AppTheme.warning, AppTheme.neonPurple],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (unit.distanceKm != null)
                _buildQuickInfoCard(
                  icon: CupertinoIcons.location_fill,
                  title: 'المسافة',
                  value: '${unit.distanceKm} كم',
                  gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.05)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📋 Tab Content
  Widget _buildTabContent(Unit unit, {Key? key}) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInfoTab(unit);
      case 1:
        return _buildGalleryTab(unit);
      case 2:
        return _buildFeaturesTab(unit);
      case 3:
        return _buildAvailabilityTab(unit);
      case 4:
        return _buildPricingTab(unit);
      default:
        return _buildInfoTab(unit);
    }
  }

  Widget _buildInfoTab(Unit unit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'معلومات الوحدة', CupertinoIcons.info_circle_fill),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('الكود', unit.name),
                _buildInfoRow('النوع', unit.unitTypeName),
                _buildInfoRow('العقار', unit.propertyName),
                if (unit.customFeatures.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  Text(
                    'الوصف',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unit.customFeatures,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textLight,
                      height: 1.5,
                    ),
                  ),
                ],
                if (unit.dynamicFields.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildDynamicFields(unit.dynamicFields),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(Unit unit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('معرض الصور', CupertinoIcons.photo_on_rectangle),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: UnitImageGallery(
              unitId: widget.unitId,
              isReadOnly: true,
              maxImages: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab(Unit unit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('المميزات والمرافق', CupertinoIcons.sparkles),
          const SizedBox(height: 16),
          if (unit.featuresList.isEmpty)
            _buildEmptyState(
              icon: CupertinoIcons.sparkles,
              message: 'لا توجد مميزات مضافة',
            )
          else
            _buildFeaturesGrid(unit.featuresList),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTab(Unit unit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('التوفر والحجوزات', CupertinoIcons.calendar),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: SizedBox(
              height: 350,
              child: UnitAvailabilityCalendar(
                unitId: widget.unitId,
                onDateSelected: (date) {
                  HapticFeedback.selectionClick();
                  // Handle date selection
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab(Unit unit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'الأسعار والعروض', CupertinoIcons.money_dollar_circle_fill),
          const SizedBox(height: 16),
          UnitPricingCards(
            basePrice: unit.basePrice,
            pricingMethod: unit.pricingMethod,
            discountPercentage: unit.discountPercentage,
            seasonalPrices: const [], // Add seasonal prices if available
          ),
        ],
      ),
    );
  }

  // 🎯 Helper Widgets
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.darkBorder.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFields(List<FieldGroupWithValues> fieldGroups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fieldGroups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.displayName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...group.fieldValues.map((field) {
                return _buildInfoRow(
                  field.displayName ?? field.fieldName ?? '',
                  field.fieldValue,
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturesGrid(List<String> features) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((feature) {
        final icon = _getFeatureIcon(feature);
        final gradient = _getFeatureGradient(feature);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withValues(alpha: 0.1)).toList(),
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient.first.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: gradient.first),
              const SizedBox(width: 8),
              Text(
                feature,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🎬 Floating Components
  Widget _buildFloatingHeader(Unit unit) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.95),
            AppTheme.darkCard.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildGlassBackButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          unit.propertyName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAnimatedPriceTag(
                    unit.basePrice,
                    unit.pricingMethod,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(Unit unit) {
    return Positioned(
      bottom: 32,
      right: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _floatingActionsController,
          curve: Curves.elasticOut,
        ),
        child: Column(
          children: [
            _buildFloatingActionButton(
              icon: CupertinoIcons.pencil,
              gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
              onTap: () => _navigateToEdit(unit),
            ),
            const SizedBox(height: 12),
            _buildFloatingActionButton(
              icon: CupertinoIcons.trash,
              gradient: [AppTheme.error, AppTheme.neonPurple],
              onTap: () => _showDeleteConfirmation(unit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(
                    alpha: 0.4 + (0.1 * _pulseAnimationController.value),
                  ),
                  blurRadius: 16 + (4 * _pulseAnimationController.value),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessButton() {
    return Positioned(
      bottom: 32,
      left: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _floatingActionsController,
          curve: Curves.elasticOut,
        ),
        child: GestureDetector(
          onTap: _showQuickAccessMenu,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.square_grid_2x2_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 Quick Access Menu
  void _showQuickAccessMenu() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _QuickAccessMenu(
        unit: (context.read<UnitDetailsBloc>().state as UnitDetailsLoaded).unit,
        onBookingTap: () {
          Navigator.pop(context);
          _navigateToBooking();
        },
        onMaintenanceTap: () {
          Navigator.pop(context);
          _navigateToMaintenance();
        },
        onReportsTap: () {
          Navigator.pop(context);
          _navigateToReports();
        },
      ),
    );
  }

  // 🔧 Helper Components
  Widget _buildGlassBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const Icon(
              CupertinoIcons.chevron_back,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPriceTag(Money price, PricingMethod method) {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(
                  alpha: 0.3 + (0.1 * _pulseAnimationController.value),
                ),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price.displayAmount,
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                method.arabicLabel,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatusBadge(bool isAvailable) {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppTheme.success.withValues(alpha: 0.2)
                : AppTheme.warning.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAvailable
                  ? AppTheme.success.withValues(alpha: 0.5)
                  : AppTheme.warning.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isAvailable ? AppTheme.success : AppTheme.warning,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAvailable ? AppTheme.success : AppTheme.warning)
                          .withValues(
                              alpha: 0.6 * _pulseAnimationController.value),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isAvailable ? 'متاحة' : 'محجوزة',
                style: AppTextStyles.caption.copyWith(
                  color: isAvailable ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎯 State Builders
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const CupertinoActivityIndicator(
              color: Colors.white,
              radius: 16,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: AppTheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
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
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    IconData icon = CupertinoIcons.cube_box,
    String message = 'لا توجد بيانات',
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _loadUnitDetails();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.refresh,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'إعادة المحاولة',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 Helper Methods
  IconData _getFeatureIcon(String feature) {
    final featureLower = feature.toLowerCase();
    if (featureLower.contains('واي فاي') || featureLower.contains('wifi')) {
      return CupertinoIcons.wifi;
    } else if (featureLower.contains('تكييف') || featureLower.contains('ac')) {
      return CupertinoIcons.snow;
    } else if (featureLower.contains('مطبخ')) {
      return CupertinoIcons.flame_fill;
    } else if (featureLower.contains('موقف') ||
        featureLower.contains('parking')) {
      return CupertinoIcons.car_fill;
    } else if (featureLower.contains('مسبح') || featureLower.contains('pool')) {
      return CupertinoIcons.drop_fill;
    } else if (featureLower.contains('جيم') || featureLower.contains('gym')) {
      return CupertinoIcons.bolt_fill;
    } else {
      return CupertinoIcons.checkmark_circle_fill;
    }
  }

  List<Color> _getFeatureGradient(String feature) {
    final featureLower = feature.toLowerCase();
    if (featureLower.contains('واي فاي') || featureLower.contains('wifi')) {
      return [AppTheme.primaryBlue, AppTheme.primaryCyan];
    } else if (featureLower.contains('تكييف') || featureLower.contains('ac')) {
      return [AppTheme.info, AppTheme.neonBlue];
    } else if (featureLower.contains('مطبخ')) {
      return [AppTheme.warning, AppTheme.neonPurple];
    } else if (featureLower.contains('موقف') ||
        featureLower.contains('parking')) {
      return [AppTheme.primaryPurple, AppTheme.primaryViolet];
    } else if (featureLower.contains('مسبح') || featureLower.contains('pool')) {
      return [AppTheme.primaryCyan, AppTheme.neonBlue];
    } else if (featureLower.contains('جيم') || featureLower.contains('gym')) {
      return [AppTheme.success, AppTheme.neonGreen];
    } else {
      return [AppTheme.primaryBlue, AppTheme.primaryPurple];
    }
  }

  // 🔧 State Handlers
  void _handleStateChanges(BuildContext context, UnitDetailsState state) {
    if (state is UnitDeleted) {
      _showSuccessSnackBar('تم حذف الوحدة بنجاح');
      context.pop();
    } else if (state is UnitDetailsError) {
      _showErrorSnackBar(state.message);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // 🎯 Navigation Methods
  void _navigateToEdit(Unit unit) {
    context.push('/admin/units/${unit.id}/edit');
  }

  void _navigateToBooking() {
    context.push('/admin/units/${widget.unitId}/booking');
  }

  void _navigateToMaintenance() {
    context.push('/admin/units/${widget.unitId}/maintenance');
  }

  void _navigateToReports() {
    context.push('/admin/units/${widget.unitId}/reports');
  }

  void _toggleFavorite(Unit unit) {
    HapticFeedback.mediumImpact();
    // Implement favorite toggle
  }

  void _shareUnit(Unit unit) {
    HapticFeedback.mediumImpact();
    // Implement share functionality
  }

  void _showDeleteConfirmation(Unit unit) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        unitName: unit.name,
        onConfirm: () {
          Navigator.pop(context);
          context.read<UnitDetailsBloc>().add(
                DeleteUnitDetailsEvent(unitId: unit.id),
              );
        },
      ),
    );
  }
}

// 🗂️ Tab Item Model
class _TabItem {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}

// 🎯 Futuristic Tab Bar Delegate
class _FuturisticTabBarDelegate extends SliverPersistentHeaderDelegate {
  final List<_TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  _FuturisticTabBarDelegate({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scrollPercentage = shrinkOffset / maxExtent;

    return Container(
      height: maxExtent,
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(
          alpha: 0.95 + (0.05 * scrollPercentage),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15 + (5 * scrollPercentage),
            sigmaY: 15 + (5 * scrollPercentage),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: tab.gradient)
                          : null,
                      color: isSelected
                          ? null
                          : AppTheme.darkCard.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppTheme.darkBorder.withValues(alpha: 0.2),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    tab.gradient.first.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                isSelected ? Colors.white : AppTheme.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// 🌌 Particle Background Painter
class _ParticleBackgroundPainter extends CustomPainter {
  final double animation;
  final double pulseAnimation;

  _ParticleBackgroundPainter({
    required this.animation,
    required this.pulseAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 5; i++) {
      final progress = (animation + i * 0.2) % 1.0;
      final y = size.height * progress;
      final x = size.width * (0.2 + 0.6 * math.sin(progress * math.pi * 2 + i));
      final radius = 3 + (2 * pulseAnimation);
      final opacity = 0.1 * (1 - progress);

      paint.shader = RadialGradient(
        colors: [
          AppTheme.primaryBlue.withValues(alpha: opacity),
          AppTheme.primaryPurple.withValues(alpha: opacity * 0.5),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius * 10));

      canvas.drawCircle(Offset(x, y), radius * 10, paint);
    }

    // Draw gradient orbs
    for (int i = 0; i < 3; i++) {
      final progress = (animation + i * 0.33) % 1.0;
      final radius = 150 + (50 * math.sin(progress * math.pi * 2));
      final opacity = 0.03 + (0.02 * pulseAnimation);

      paint.shader = RadialGradient(
        colors: [
          AppTheme.primaryPurple.withValues(alpha: opacity),
          AppTheme.primaryViolet.withValues(alpha: opacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * (0.3 + 0.4 * math.cos(progress * math.pi * 2 + i)),
          size.height * (0.3 + 0.4 * math.sin(progress * math.pi * 2 + i)),
        ),
        radius: radius,
      ));

      canvas.drawCircle(
        Offset(
          size.width * (0.3 + 0.4 * math.cos(progress * math.pi * 2 + i)),
          size.height * (0.3 + 0.4 * math.sin(progress * math.pi * 2 + i)),
        ),
        radius,
        paint,
      );
    }

    // Draw grid lines
    paint.shader = null;
    paint.color = AppTheme.primaryBlue.withValues(alpha: 0.02);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    const gridSize = 50.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 🎯 Quick Access Menu
class _QuickAccessMenu extends StatelessWidget {
  final Unit unit;
  final VoidCallback onBookingTap;
  final VoidCallback onMaintenanceTap;
  final VoidCallback onReportsTap;

  const _QuickAccessMenu({
    required this.unit,
    required this.onBookingTap,
    required this.onMaintenanceTap,
    required this.onReportsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'إجراءات سريعة',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 20),

              // Menu Items
              _buildMenuItem(
                icon: CupertinoIcons.calendar_badge_plus,
                label: 'حجز جديد',
                subtitle: 'إنشاء حجز جديد لهذه الوحدة',
                gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                onTap: onBookingTap,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.wrench_fill,
                label: 'الصيانة',
                subtitle: 'إدارة طلبات الصيانة والإصلاحات',
                gradient: [AppTheme.warning, AppTheme.neonPurple],
                onTap: onMaintenanceTap,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'التقارير',
                subtitle: 'عرض تقارير الأداء والإحصائيات',
                gradient: [AppTheme.success, AppTheme.neonGreen],
                onTap: onReportsTap,
              ),
              _buildMenuItem(
                icon: CupertinoIcons.qrcode,
                label: 'QR Code',
                subtitle: 'إنشاء رمز QR للوحدة',
                gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  // Generate QR code
                },
              ),

              const SizedBox(height: 20),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.05)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppTheme.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🗑️ Delete Confirmation Dialog
class _DeleteConfirmationDialog extends StatelessWidget {
  final String unitName;
  final VoidCallback onConfirm;

  const _DeleteConfirmationDialog({
    required this.unitName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.95),
              AppTheme.darkCard.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.error.withValues(alpha: 0.2),
                        AppTheme.error.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.trash_fill,
                    color: AppTheme.error,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'تأكيد الحذف',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'هل أنت متأكد من حذف وحدة "$unitName"؟',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'لا يمكن التراجع عن هذا الإجراء',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.darkBorder.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'إلغاء',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onConfirm();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.error,
                                AppTheme.error.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.error.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'حذف',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
}
