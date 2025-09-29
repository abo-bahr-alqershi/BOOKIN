import 'package:bookn_cp_app/features/admin_sections/domain/entities/section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';
import '../../../../core/enums/section_target.dart';
import '../bloc/section_form/section_form_bloc.dart';
import '../bloc/section_form/section_form_event.dart';
import '../bloc/section_form/section_form_state.dart';
import 'section_type_selector.dart';
import 'section_content_type_toggle.dart';
import 'section_display_style_picker.dart';
import 'section_filter_criteria_editor.dart';
import 'section_sort_criteria_editor.dart';
import 'section_metadata_editor.dart';
import 'section_schedule_picker.dart';
import 'section_preview_widget.dart';

class SectionFormWidget extends StatefulWidget {
  final bool isEditing;
  final String? sectionId;

  const SectionFormWidget({
    super.key,
    required this.isEditing,
    this.sectionId,
  });

  @override
  State<SectionFormWidget> createState() => _SectionFormWidgetState();
}

class _SectionFormWidgetState extends State<SectionFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late AnimationController _tabAnimationController;
  late List<Animation<double>> _tabAnimations;

  // Controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _displayOrderController = TextEditingController();
  final _columnsCountController = TextEditingController();
  final _itemsToShowController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorThemeController = TextEditingController();
  final _backgroundImageController = TextEditingController();

  // State with default values
  SectionTypeEnum _selectedType = SectionTypeEnum.featured;
  SectionContentType _selectedContentType = SectionContentType.properties;
  SectionDisplayStyle _selectedDisplayStyle = SectionDisplayStyle.grid;
  SectionTarget _selectedTarget = SectionTarget.properties;
  bool _isActive = true;
  bool _isVisibleToGuests = true;
  bool _isVisibleToRegistered = true;
  String? _requiresPermission;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic> _filterCriteria = {};
  Map<String, dynamic> _sortCriteria = {};
  String _metadata = '';
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _setupTabAnimations();
    _tabAnimationController.forward();

    // Set default values for required fields
    _displayOrderController.text = '0';
    _columnsCountController.text = '2';
    _itemsToShowController.text = '10';

    // Initialize form
    context.read<SectionFormBloc>().add(
          InitializeSectionFormEvent(sectionId: widget.sectionId),
        );
  }

  void _setupTabAnimations() {
    _tabAnimations = List.generate(5, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _tabAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabAnimationController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _displayOrderController.dispose();
    _columnsCountController.dispose();
    _itemsToShowController.dispose();
    _iconController.dispose();
    _colorThemeController.dispose();
    _backgroundImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SectionFormBloc, SectionFormState>(
      listener: (context, state) {
        if (state is SectionFormReady &&
            widget.isEditing &&
            widget.sectionId != null) {
          _populateForm(state);
        } else if (state is SectionFormSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'تم تحديث القسم بنجاح'
                  : 'تم إضافة القسم بنجاح'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is SectionFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SectionFormLoading && widget.isEditing) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAnimatedTabs(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBasicInfoTab(),
                        _buildConfigurationTab(),
                        _buildAppearanceTab(),
                        _buildFiltersAndSortingTab(),
                        _buildAdvancedTab(),
                      ],
                    ),
                  ),
                  _buildActionButtons(state),
                ],
              ),
            ),
            if (_showPreview) _buildPreviewOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTabs() {
    final tabs = [
      'معلومات أساسية',
      'الإعدادات',
      'المظهر',
      'الفلترة والترتيب',
      'متقدم',
    ];

    final icons = [
      CupertinoIcons.info_circle_fill,
      CupertinoIcons.settings,
      CupertinoIcons.paintbrush_fill,
      CupertinoIcons.slider_horizontal_3,
      CupertinoIcons.gear_alt_fill,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: AppTheme.primaryBlue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: List.generate(tabs.length, (index) {
          return AnimatedBuilder(
            animation: _tabAnimations[index],
            builder: (context, child) {
              final animationValue =
                  _tabAnimations[index].value.clamp(0.0, 1.0);
              final scaleValue = 0.9 + (animationValue * 0.1);

              return Transform.scale(
                scale: scaleValue,
                child: Opacity(
                  opacity: animationValue,
                  child: Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[index], size: 16),
                        const SizedBox(width: 8),
                        Text(tabs[index]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildScrollableContent({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'المعلومات الأساسية', CupertinoIcons.info_circle_fill),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _nameController,
              label: 'اسم القسم (داخلي)',
              hint: 'أدخل اسم القسم للاستخدام الداخلي',
              icon: Icons.label_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم القسم مطلوب';
                }
                return null;
              },
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(name: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _titleController,
              label: 'العنوان',
              hint: 'أدخل عنوان القسم',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'العنوان مطلوب';
                }
                return null;
              },
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(title: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _subtitleController,
              label: 'العنوان الفرعي',
              hint: 'أدخل عنوان فرعي (اختياري)',
              icon: Icons.subtitles_outlined,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(subtitle: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _descriptionController,
              label: 'الوصف',
              hint: 'أدخل وصف القسم',
              icon: Icons.description_outlined,
              maxLines: 3,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(description: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _shortDescriptionController,
              label: 'وصف مختصر',
              hint: 'أدخل وصف مختصر للعرض السريع',
              icon: Icons.short_text,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(shortDescription: value),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('إعدادات القسم', CupertinoIcons.settings),
            const SizedBox(height: 20),
            SectionTypeSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() => _selectedType = type);
                context.read<SectionFormBloc>().add(
                      UpdateSectionConfigEvent(type: type),
                    );
              },
            ),
            const SizedBox(height: 20),
            SectionContentTypeToggle(
              selectedType: _selectedContentType,
              onTypeSelected: (type) {
                setState(() => _selectedContentType = type);
                context.read<SectionFormBloc>().add(
                      UpdateSectionConfigEvent(contentType: type),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildTargetSelector(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _displayOrderController,
                    label: 'ترتيب العرض',
                    hint: '0',
                    icon: Icons.format_list_numbered,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الترتيب مطلوب';
                      }
                      if (int.tryParse(value) == null) {
                        return 'أدخل رقم صحيح';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final order = int.tryParse(value);
                      if (order != null) {
                        context.read<SectionFormBloc>().add(
                              UpdateSectionConfigEvent(displayOrder: order),
                            );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    controller: _itemsToShowController,
                    label: 'عدد العناصر',
                    hint: '10',
                    icon: Icons.view_module,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'العدد مطلوب';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 1) {
                        return 'أدخل رقم صحيح أكبر من 0';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      if (count != null) {
                        context.read<SectionFormBloc>().add(
                              UpdateSectionConfigEvent(itemsToShow: count),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActiveSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'إعدادات المظهر', CupertinoIcons.paintbrush_fill),
            const SizedBox(height: 20),
            SectionDisplayStylePicker(
              selectedStyle: _selectedDisplayStyle,
              onStyleSelected: (style) {
                setState(() => _selectedDisplayStyle = style);
                context.read<SectionFormBloc>().add(
                      UpdateSectionConfigEvent(displayStyle: style),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _columnsCountController,
              label: 'عدد الأعمدة',
              hint: '2',
              icon: Icons.view_column,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'عدد الأعمدة مطلوب';
                }
                final count = int.tryParse(value);
                if (count == null || count < 1 || count > 6) {
                  return 'أدخل رقم بين 1 و 6';
                }
                return null;
              },
              onChanged: (value) {
                final count = int.tryParse(value);
                if (count != null) {
                  context.read<SectionFormBloc>().add(
                        UpdateSectionConfigEvent(columnsCount: count),
                      );
                }
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _iconController,
              label: 'أيقونة القسم',
              hint: 'اسم الأيقونة (اختياري)',
              icon: Icons.insert_emoticon,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionAppearanceEvent(icon: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _colorThemeController,
              label: 'لون القسم',
              hint: 'كود اللون (اختياري)',
              icon: Icons.palette,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionAppearanceEvent(colorTheme: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _backgroundImageController,
              label: 'صورة الخلفية',
              hint: 'رابط الصورة (اختياري)',
              icon: Icons.image,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionAppearanceEvent(backgroundImage: value),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSortingTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'الفلترة والترتيب', CupertinoIcons.slider_horizontal_3),
            const SizedBox(height: 20),
            SectionFilterCriteriaEditor(
              initialCriteria: _filterCriteria,
              onCriteriaChanged: (criteria) {
                setState(() => _filterCriteria = criteria);
                context.read<SectionFormBloc>().add(
                      UpdateSectionFiltersEvent(
                        filterCriteriaJson: criteria.toString(),
                        cityName: criteria['cityName'],
                        propertyTypeId: criteria['propertyTypeId'],
                        unitTypeId: criteria['unitTypeId'],
                        minPrice: criteria['minPrice'],
                        maxPrice: criteria['maxPrice'],
                        minRating: criteria['minRating'],
                      ),
                    );
              },
            ),
            const SizedBox(height: 30),
            SectionSortCriteriaEditor(
              initialCriteria: _sortCriteria,
              onCriteriaChanged: (criteria) {
                setState(() => _sortCriteria = criteria);
                context.read<SectionFormBloc>().add(
                      UpdateSectionFiltersEvent(
                        sortCriteriaJson: criteria.toString(),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('إعدادات متقدمة', CupertinoIcons.gear_alt_fill),
            const SizedBox(height: 20),
            SectionSchedulePicker(
              startDate: _startDate,
              endDate: _endDate,
              onScheduleChanged: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                context.read<SectionFormBloc>().add(
                      UpdateSectionVisibilityEvent(
                        startDate: start,
                        endDate: end,
                      ),
                    );
              },
            ),
            const SizedBox(height: 30),
            _buildVisibilitySettings(),
            const SizedBox(height: 30),
            SectionMetadataEditor(
              initialMetadata: _metadata,
              onMetadataChanged: (metadata) {
                setState(() => _metadata = metadata);
                context.read<SectionFormBloc>().add(
                      UpdateSectionMetadataEvent(metadataJson: metadata),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilitySettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الظهور',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildVisibilitySwitch(
            label: 'مرئي للزوار',
            value: _isVisibleToGuests,
            onChanged: (value) {
              setState(() => _isVisibleToGuests = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionVisibilityEvent(isVisibleToGuests: value),
                  );
            },
          ),
          const SizedBox(height: 12),
          _buildVisibilitySwitch(
            label: 'مرئي للمسجلين',
            value: _isVisibleToRegistered,
            onChanged: (value) {
              setState(() => _isVisibleToRegistered = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionVisibilityEvent(isVisibleToRegistered: value),
                  );
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: TextEditingController(text: _requiresPermission),
            label: 'الصلاحية المطلوبة',
            hint: 'اسم الصلاحية (اختياري)',
            icon: Icons.lock_outline,
            onChanged: (value) {
              setState(() => _requiresPermission = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionVisibilityEvent(requiresPermission: value),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildPreviewOverlay() {
    final section = _createSectionFromForm();

    return GestureDetector(
      onTap: () => setState(() => _showPreview = false),
      child: Container(
        color: AppTheme.darkBackground.withValues(alpha: 0.9),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'معاينة القسم',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showPreview = false),
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SectionPreviewWidget(
                        section: section,
                        isExpanded: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
              prefixIcon: maxLines == 1
                  ? Icon(
                      icon,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الهدف',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTargetOption(
                label: 'العقارات',
                value: SectionTarget.properties,
                isSelected: _selectedTarget == SectionTarget.properties,
                onTap: () {
                  setState(() => _selectedTarget = SectionTarget.properties);
                  context.read<SectionFormBloc>().add(
                        const UpdateSectionConfigEvent(
                            target: SectionTarget.properties),
                      );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTargetOption(
                label: 'الوحدات',
                value: SectionTarget.units,
                isSelected: _selectedTarget == SectionTarget.units,
                onTap: () {
                  setState(() => _selectedTarget = SectionTarget.units);
                  context.read<SectionFormBloc>().add(
                        const UpdateSectionConfigEvent(
                            target: SectionTarget.units),
                      );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetOption({
    required String label,
    required SectionTarget value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تفعيل القسم',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoSwitch(
            value: _isActive,
            onChanged: (value) {
              setState(() => _isActive = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(isActive: value),
                  );
            },
            activeTrackColor: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SectionFormState state) {
    final isLoading = state is SectionFormLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.5),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPreview = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.3),
                    AppTheme.primaryViolet.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.eye_fill,
                    color: AppTheme.primaryPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'معاينة',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              child: Text(
                'إلغاء',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isLoading ? null : _submitForm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: isLoading
                    ? LinearGradient(colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.5),
                        AppTheme.primaryBlue.withValues(alpha: 0.3),
                      ])
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isEditing ? 'تحديث' : 'إضافة',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _populateForm(SectionFormReady state) {
    if (state.sectionId != null && state.sectionId!.isNotEmpty) {
      _nameController.text = state.name ?? '';
      _titleController.text = state.title ?? '';
      _subtitleController.text = state.subtitle ?? '';
      _descriptionController.text = state.description ?? '';
      _shortDescriptionController.text = state.shortDescription ?? '';
      _displayOrderController.text = state.displayOrder?.toString() ?? '0';
      _columnsCountController.text = state.columnsCount?.toString() ?? '2';
      _itemsToShowController.text = state.itemsToShow?.toString() ?? '10';
      _iconController.text = state.icon ?? '';
      _colorThemeController.text = state.colorTheme ?? '';
      _backgroundImageController.text = state.backgroundImage ?? '';

      setState(() {
        _selectedType = state.type ?? SectionTypeEnum.featured;
        _selectedContentType =
            state.contentType ?? SectionContentType.properties;
        _selectedDisplayStyle = state.displayStyle ?? SectionDisplayStyle.grid;
        _selectedTarget = state.target ?? SectionTarget.properties;
        _isActive = state.isActive ?? true;
        _isVisibleToGuests = state.isVisibleToGuests ?? true;
        _isVisibleToRegistered = state.isVisibleToRegistered ?? true;
        _requiresPermission = state.requiresPermission;
        _startDate = state.startDate;
        _endDate = state.endDate;
        _metadata = state.metadataJson ?? '';
      });
    }
  }

  Section _createSectionFromForm() {
    return Section(
      id: widget.sectionId ?? '',
      type: _selectedType,
      contentType: _selectedContentType,
      displayStyle: _selectedDisplayStyle,
      name: _nameController.text.isEmpty
          ? _titleController.text
          : _nameController.text,
      title: _titleController.text,
      subtitle:
          _subtitleController.text.isEmpty ? null : _subtitleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      shortDescription: _shortDescriptionController.text.isEmpty
          ? null
          : _shortDescriptionController.text,
      displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
      target: _selectedTarget,
      isActive: _isActive,
      columnsCount: int.tryParse(_columnsCountController.text) ?? 2,
      itemsToShow: int.tryParse(_itemsToShowController.text) ?? 10,
      icon: _iconController.text.isEmpty ? null : _iconController.text,
      colorTheme: _colorThemeController.text.isEmpty
          ? null
          : _colorThemeController.text,
      backgroundImage: _backgroundImageController.text.isEmpty
          ? null
          : _backgroundImageController.text,
      filterCriteria:
          _filterCriteria.isNotEmpty ? _filterCriteria.toString() : null,
      sortCriteria: _sortCriteria.isNotEmpty ? _sortCriteria.toString() : null,
      cityName: _filterCriteria['cityName'],
      propertyTypeId: _filterCriteria['propertyTypeId'],
      unitTypeId: _filterCriteria['unitTypeId'],
      minPrice: _filterCriteria['minPrice'],
      maxPrice: _filterCriteria['maxPrice'],
      minRating: _filterCriteria['minRating'],
      isVisibleToGuests: _isVisibleToGuests,
      isVisibleToRegistered: _isVisibleToRegistered,
      requiresPermission: _requiresPermission,
      startDate: _startDate,
      endDate: _endDate,
      metadata: _metadata.isEmpty ? null : _metadata,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // التحقق من الحقول المطلوبة
      if (_nameController.text.isEmpty) {
        _nameController.text = _titleController.text;
      }

      // التأكد من تحديث جميع البيانات قبل الإرسال
      context.read<SectionFormBloc>().add(
            UpdateSectionBasicInfoEvent(
              name: _nameController.text,
              title: _titleController.text,
              subtitle: _subtitleController.text.isEmpty
                  ? null
                  : _subtitleController.text,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              shortDescription: _shortDescriptionController.text.isEmpty
                  ? null
                  : _shortDescriptionController.text,
            ),
          );

      context.read<SectionFormBloc>().add(
            UpdateSectionConfigEvent(
              type: _selectedType,
              contentType: _selectedContentType,
              displayStyle: _selectedDisplayStyle,
              target: _selectedTarget,
              displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
              itemsToShow: int.tryParse(_itemsToShowController.text) ?? 10,
              columnsCount: int.tryParse(_columnsCountController.text) ?? 2,
              isActive: _isActive,
            ),
          );

      // تأكد من أن معايير الفلترة والترتيب يتم إرسالها كسلاسل JSON صحيحة
      final String? filterJson = _filterCriteria.isNotEmpty
          ? (() {
              try {
                return _filterCriteria.isNotEmpty
                    ? const JsonEncoder.withIndent('  ').convert(_filterCriteria)
                    : null;
              } catch (_) {
                return _filterCriteria.toString();
              }
            })()
          : null;

      final String? sortJson = _sortCriteria.isNotEmpty
          ? (() {
              try {
                return const JsonEncoder.withIndent('  ').convert(_sortCriteria);
              } catch (_) {
                return _sortCriteria.toString();
              }
            })()
          : null;

      if (filterJson != null || sortJson != null) {
        context.read<SectionFormBloc>().add(
              UpdateSectionFiltersEvent(
                filterCriteriaJson: filterJson,
                sortCriteriaJson: sortJson,
                cityName: _filterCriteria['cityName'],
                propertyTypeId: _filterCriteria['propertyTypeId'],
                unitTypeId: _filterCriteria['unitTypeId'],
                minPrice: _filterCriteria['minPrice'],
                maxPrice: _filterCriteria['maxPrice'],
                minRating: _filterCriteria['minRating'],
              ),
            );
      }

      // إرسال الطلب النهائي بعد التأكد من تزامن تحديث الحالة
      Future.delayed(const Duration(milliseconds: 120), () {
        context.read<SectionFormBloc>().add(SubmitSectionFormEvent());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}
