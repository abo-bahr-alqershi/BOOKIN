import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/enums/section_target.dart';
import '../../domain/entities/property_in_section.dart';
import '../../domain/entities/unit_in_section.dart';
import '../bloc/section_items/section_items_bloc.dart';
import '../bloc/section_items/section_items_event.dart';
import '../bloc/section_items/section_items_state.dart';
import '../widgets/section_items_list.dart';
import '../widgets/add_items_dialog.dart';

class SectionItemsManagementPage extends StatefulWidget {
  final String sectionId;
  final SectionTarget target;

  const SectionItemsManagementPage({
    super.key,
    required this.sectionId,
    required this.target,
  });

  @override
  State<SectionItemsManagementPage> createState() =>
      _SectionItemsManagementPageState();
}

class _SectionItemsManagementPageState extends State<SectionItemsManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadItems();
  }

  void _loadItems() {
    context.read<SectionItemsBloc>().add(
          LoadSectionItemsEvent(
            sectionId: widget.sectionId,
            target: widget.target,
            pageNumber: 1,
            pageSize: 20,
          ),
        );
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildActionBar(),
            Expanded(
              child: BlocBuilder<SectionItemsBloc, SectionItemsState>(
                builder: (context, state) {
                  if (state is SectionItemsLoading) {
                    return const LoadingWidget(
                      type: LoadingType.futuristic,
                      message: 'جاري تحميل العناصر...',
                    );
                  }

                  if (state is SectionItemsError) {
                    return CustomErrorWidget(
                      message: state.message,
                      onRetry: _loadItems,
                    );
                  }

                  if (state is SectionItemsLoaded) {
                    if (state.page.items.isEmpty) {
                      return EmptyWidget(
                        message: 'لا توجد عناصر في هذا القسم',
                        actionWidget: _buildAddButton(),
                      );
                    }

                    return SectionItemsList(
                      items: state.page.items,
                      target: widget.target,
                      isReordering: _isReordering,
                      onReorder: _handleReorder,
                      onRemove: _handleRemove,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkSurface.withValues(alpha: 0.5),
                    AppTheme.darkSurface.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textWhite,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'إدارة عناصر القسم',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.target == SectionTarget.properties
                      ? 'العقارات في القسم'
                      : 'الوحدات في القسم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildActionChip(
            icon: _isReordering
                ? CupertinoIcons.checkmark_circle
                : CupertinoIcons.arrow_up_arrow_down,
            label: _isReordering ? 'حفظ الترتيب' : 'إعادة الترتيب',
            onTap: () {
              setState(() {
                _isReordering = !_isReordering;
              });
              if (!_isReordering) {
                _saveOrder();
              }
            },
            isPrimary: _isReordering,
          ),
          const SizedBox(width: 8),
          _buildActionChip(
            icon: CupertinoIcons.arrow_clockwise,
            label: 'تحديث',
            onTap: _loadItems,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : AppTheme.darkBorder.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isPrimary ? Colors.white : AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _showAddItemsDialog,
      icon: const Icon(CupertinoIcons.plus),
      label: const Text('إضافة عناصر'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddItemsDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          CupertinoIcons.plus,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showAddItemsDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemsDialog(
        sectionId: widget.sectionId,
        target: widget.target,
        onItemsAdded: _loadItems,
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    // TODO: Implement reorder logic
  }

  void _handleRemove(String itemId) {
    context.read<SectionItemsBloc>().add(
          RemoveItemsFromSectionEvent(
            sectionId: widget.sectionId,
            itemIds: [itemId],
          ),
        );
  }

  void _saveOrder() {
    // TODO: Implement save order logic
  }
}
