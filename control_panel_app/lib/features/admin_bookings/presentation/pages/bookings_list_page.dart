// lib/features/admin_bookings/presentation/pages/bookings_list_page.dart

import 'package:bookn_cp_app/features/admin_bookings/domain/entities/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../bloc/bookings_list/bookings_list_bloc.dart';
import '../bloc/bookings_list/bookings_list_event.dart';
import '../bloc/bookings_list/bookings_list_state.dart';
import '../widgets/futuristic_booking_card.dart';
import '../widgets/futuristic_bookings_table.dart';
import '../widgets/booking_filters_widget.dart';
import '../widgets/booking_stats_cards.dart';
import 'booking_details_page.dart';
import 'booking_calendar_page.dart';

class BookingsListPage extends StatefulWidget {
  const BookingsListPage({super.key});

  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  bool _isGridView = false;
  bool _showFilters = false;
  BookingFilters? _activeFilters;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
    _setupScrollListener();
  }

  void _loadBookings() {
    context.read<BookingsListBloc>().add(
          LoadBookingsEvent(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
            pageNumber: 1,
            pageSize: 20,
          ),
        );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more when near bottom
        final state = context.read<BookingsListBloc>().state;
        if (state is BookingsListLoaded && state.bookings.hasNextPage) {
          context.read<BookingsListBloc>().add(
                ChangePageEvent(
                  pageNumber: state.bookings.nextPageNumber!,
                ),
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(),
          _buildStatsSection(),
          _buildFilterSection(),
          _buildBookingsList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'الحجوزات',
          style: AppTextStyles.heading1.copyWith(
            color: AppTheme.textWhite,
            shadows: [
              Shadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.1),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildActionButton(
          icon: _isGridView
              ? CupertinoIcons.list_bullet
              : CupertinoIcons.square_grid_2x2,
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        _buildActionButton(
          icon: CupertinoIcons.calendar,
          onPressed: () => context.push('/admin/bookings/calendar'),
        ),
        _buildActionButton(
          icon: _showFilters
              ? CupertinoIcons.xmark
              : CupertinoIcons.slider_horizontal_3,
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: AppTheme.textWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<BookingsListBloc, BookingsListState>(
        builder: (context, state) {
          if (state is! BookingsListLoaded) return const SizedBox.shrink();

          return AnimationLimiter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BookingStatsCards(
                bookings: state.bookings.items,
                stats: state.stats ?? {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showFilters ? 180 : 0,
        child: _showFilters
            ? BookingFiltersWidget(
                initialFilters: _activeFilters,
                onFiltersChanged: (filters) {
                  setState(() => _activeFilters = filters);
                  context.read<BookingsListBloc>().add(
                        FilterBookingsEvent(
                          startDate: filters.startDate,
                          endDate: filters.endDate,
                          userId: filters.userId,
                          unitId: filters.unitId,
                          bookingSource: filters.bookingSource,
                        ),
                      );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBookingsList() {
    return BlocBuilder<BookingsListBloc, BookingsListState>(
      builder: (context, state) {
        if (state is BookingsListLoading) {
          return const SliverFillRemaining(
            child: LoadingWidget(
              type: LoadingType.shimmer,
              message: 'جاري تحميل الحجوزات...',
            ),
          );
        }

        if (state is BookingsListError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadBookings,
            ),
          );
        }

        if (state is BookingsListLoaded) {
          if (state.bookings.items.isEmpty) {
            return const SliverFillRemaining(
              child: EmptyWidget(
                message: 'لا توجد حجوزات حالياً',
              ),
            );
          }

          return _isGridView ? _buildGridView(state) : _buildTableView(state);
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildGridView(BookingsListLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final booking = state.bookings.items[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: FuturisticBookingCard(
                    booking: booking,
                    isSelected: state.selectedBookings.contains(booking),
                    onTap: () => _navigateToDetails(booking.id),
                    onLongPress: () => _toggleSelection(booking),
                  ),
                ),
              ),
            );
          },
          childCount: state.bookings.items.length,
        ),
      ),
    );
  }

  Widget _buildTableView(BookingsListLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturisticBookingsTable(
          bookings: state.bookings.items,
          selectedBookings: state.selectedBookings,
          onBookingTap: _navigateToDetails,
          onSelectionChanged: (bookings) {
            context.read<BookingsListBloc>().add(
                  SelectMultipleBookingsEvent(
                    bookingIds: bookings.map((b) => b.id).toList(),
                  ),
                );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<BookingsListBloc, BookingsListState>(
      builder: (context, state) {
        if (state is! BookingsListLoaded || state.selectedBookings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _showBulkActions,
            backgroundColor: Colors.transparent,
            elevation: 0,
            label: Text(
              '${state.selectedBookings.length} محدد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetails(String bookingId) {
    context.push('/admin/bookings/$bookingId');
  }

  void _toggleSelection(Booking booking) {
    final bloc = context.read<BookingsListBloc>();
    final state = bloc.state;

    if (state is BookingsListLoaded) {
      if (state.selectedBookings.contains(booking)) {
        bloc.add(DeselectBookingEvent(bookingId: booking.id));
      } else {
        bloc.add(SelectBookingEvent(bookingId: booking.id));
      }
    }
  }

  void _showBulkActions() {
    // Show bottom sheet with bulk actions
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Bulk action buttons
            _buildBulkActionButton(
              icon: CupertinoIcons.checkmark_circle,
              label: 'تأكيد الكل',
              onTap: () {},
            ),
            _buildBulkActionButton(
              icon: CupertinoIcons.xmark_circle,
              label: 'إلغاء الكل',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
