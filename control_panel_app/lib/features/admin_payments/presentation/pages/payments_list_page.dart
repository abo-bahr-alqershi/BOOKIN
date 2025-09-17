import 'package:bookn_cp_app/features/admin_bookings/presentation/bloc/booking_analytics/booking_analytics_event.dart'
    hide ExportFormat;
import 'package:bookn_cp_app/features/admin_payments/presentation/bloc/payments_list/payments_list_bloc.dart';
import 'package:bookn_cp_app/features/admin_payments/presentation/bloc/payments_list/payments_list_event.dart';
import 'package:bookn_cp_app/features/admin_payments/presentation/bloc/payments_list/payments_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../widgets/futuristic_payments_table.dart';
import '../widgets/payment_filters_widget.dart';
import '../widgets/payment_stats_cards.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/theme/app_dimensions.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../core/widgets/error_widget.dart';
import 'payment_details_page.dart';

class PaymentsListPage extends StatefulWidget {
  const PaymentsListPage({super.key});

  @override
  State<PaymentsListPage> createState() => _PaymentsListPageState();
}

class _PaymentsListPageState extends State<PaymentsListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load payments
    context.read<PaymentsListBloc>().add(const LoadPaymentsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<PaymentsListBloc, PaymentsListState>(
                  builder: (context, state) {
                    if (state is PaymentsListLoading) {
                      return const LoadingWidget(
                        type: LoadingType.shimmer,
                        message: 'جاري تحميل المدفوعات...',
                      );
                    }

                    if (state is PaymentsListError) {
                      return CustomErrorWidget(
                        message: state.message,
                        type: ErrorType.general,
                        onRetry: () {
                          context.read<PaymentsListBloc>().add(
                                const RefreshPaymentsEvent(),
                              );
                        },
                      );
                    }

                    if (state is PaymentsListLoaded) {
                      return _buildLoadedContent(state);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    color: AppTheme.textWhite,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        'إدارة المدفوعات',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'متابعة وإدارة جميع المعاملات المالية',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Filter Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: _showFilters ? AppTheme.primaryGradient : null,
                    color: _showFilters ? null : AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showFilters
                          ? Colors.transparent
                          : AppTheme.darkBorder,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: AppTheme.textWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Filters
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? 120 : 0,
            child: _showFilters
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: const PaymentFiltersWidget(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(PaymentsListLoaded state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: PaymentStatsCards(
                statistics: state.statistics,
              ),
            ),
          ),

          // Payments Table
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            sliver: SliverToBoxAdapter(
              child: FuturisticPaymentsTable(
                payments: state.payments.items,
                onPaymentTap: (payment) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => PaymentDetailsPage(
                        paymentId: payment.id,
                      ),
                    ),
                  );
                },
                onRefundTap: (payment) {
                  context.read<PaymentsListBloc>().add(
                        RefundPaymentEvent(
                          paymentId: payment.id,
                          refundAmount: payment.amount,
                          refundReason: 'طلب العميل',
                        ),
                      );
                },
                onVoidTap: (payment) {
                  context.read<PaymentsListBloc>().add(
                        VoidPaymentEvent(paymentId: payment.id),
                      );
                },
              ),
            ),
          ),

          // Pagination
          if (state.payments.hasNextPage)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Center(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      context.read<PaymentsListBloc>().add(
                            ChangePageEvent(
                              pageNumber: state.payments.currentPage + 1,
                            ),
                          );
                    },
                    child: Text(
                      'تحميل المزيد',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          context.read<PaymentsListBloc>().add(
                const ExportPaymentsEvent(format: ExportFormat.excel),
              );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(CupertinoIcons.arrow_down_doc, size: 20),
        label: const Text(
          'تصدير',
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }
}
